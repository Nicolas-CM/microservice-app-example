package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/joho/godotenv"

	"context"
	"strings"
	"github.com/coreos/go-oidc/v3/oidc"
	"golang.org/x/oauth2"

	jwt "github.com/dgrijalva/jwt-go"
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
	gommonlog "github.com/labstack/gommon/log"
)

var (
	// ErrHttpGenericMessage that is returned in general case, details should be logged in such case
	ErrHttpGenericMessage = echo.NewHTTPError(http.StatusInternalServerError, "something went wrong, please try again later")

	// ErrWrongCredentials indicates that login attempt failed because of incorrect login or password
	ErrWrongCredentials = echo.NewHTTPError(http.StatusUnauthorized, "username or password is invalid")

	jwtSecret = "myfancysecret"

	// Auth0 config
	auth0Domain = ""
	auth0ClientID = ""
	auth0ClientSecret = ""
	auth0Issuer = ""
	auth0Provider *oidc.Provider
	auth0Verifier *oidc.IDTokenVerifier
	auth0OAuth2Config *oauth2.Config
)

func main() {
	// Cargar variables de entorno desde .env si existe
	_ = godotenv.Load()
	hostport := ":" + os.Getenv("AUTH_API_PORT")
	userAPIAddress := os.Getenv("USERS_API_ADDRESS")

	envJwtSecret := os.Getenv("JWT_SECRET")
	if len(envJwtSecret) != 0 {
		jwtSecret = envJwtSecret
	}

	// Leer variables de entorno de Auth0
	if v := os.Getenv("AUTH0_DOMAIN"); v != "" {
		auth0Domain = v
	}
	if v := os.Getenv("AUTH0_CLIENT_ID"); v != "" {
		auth0ClientID = v
	}
	if v := os.Getenv("AUTH0_CLIENT_SECRET"); v != "" {
		auth0ClientSecret = v
	}
	auth0Issuer = "https://" + auth0Domain + "/"

	// Inicializar OIDC provider y verifier
	ctx := context.Background()
	var err error
	if auth0Domain != "" && auth0ClientID != "" && auth0ClientSecret != "" {
		auth0Provider, err = oidc.NewProvider(ctx, auth0Issuer)
		if err != nil {
			log.Fatalf("Error inicializando OIDC provider: %v", err)
		}
		auth0Verifier = auth0Provider.Verifier(&oidc.Config{ClientID: auth0ClientID})
		auth0OAuth2Config = &oauth2.Config{
			ClientID:     auth0ClientID,
			ClientSecret: auth0ClientSecret,
			Endpoint:     auth0Provider.Endpoint(),
			RedirectURL:  "http://localhost:8081/auth0/callback",
			Scopes:       []string{"openid", "profile", "email"},
		}
	}

	userService := UserService{
		Client:         http.DefaultClient,
		UserAPIAddress: userAPIAddress,
		AllowedUserHashes: map[string]interface{}{
			"admin_admin": nil,
			"johnd_foo":   nil,
			"janed_ddd":   nil,
		},
	}

	e := echo.New()
	e.Logger.SetLevel(gommonlog.INFO)

	if zipkinURL := os.Getenv("ZIPKIN_URL"); len(zipkinURL) != 0 {
		e.Logger.Infof("init tracing to Zipkit at %s", zipkinURL)

		if tracedMiddleware, tracedClient, err := initTracing(zipkinURL); err == nil {
			e.Use(echo.WrapMiddleware(tracedMiddleware))
			userService.Client = tracedClient
		} else {
			e.Logger.Infof("Zipkin tracer init failed: %s", err.Error())
		}
	} else {
		e.Logger.Infof("Zipkin URL was not provided, tracing is not initialised")
	}

	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Use(middleware.CORS())

	// Middleware para validar JWT de Auth0 en rutas protegidas
	e.Use(func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			authHeader := c.Request().Header.Get("Authorization")
			if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
				return next(c) // Permitir rutas públicas
			}
			tokenString := strings.TrimPrefix(authHeader, "Bearer ")
			ctx := c.Request().Context()
			if auth0Verifier != nil {
				_, err := auth0Verifier.Verify(ctx, tokenString)
				if err == nil {
					return next(c)
				}
			}
			// Si no es válido con Auth0, seguir con el flujo normal (JWT local)
			return next(c)
		}
	})

	// Route => handler
	e.GET("/version", func(c echo.Context) error {
		return c.String(http.StatusOK, "Auth API, written in Go\n")
	})

	e.POST("/login", getLoginHandler(userService))

	// Endpoint para redirigir a Auth0 (inicio de login federado)
	e.GET("/auth0/login", func(c echo.Context) error {
		if auth0OAuth2Config == nil {
			return c.String(http.StatusInternalServerError, "Auth0 no está configurado")
		}
		state := "state" // En producción, genera un valor aleatorio y guárdalo en sesión
		url := auth0OAuth2Config.AuthCodeURL(state)
		return c.Redirect(http.StatusTemporaryRedirect, url)
	})

	// Endpoint callback de Auth0
	e.GET("/auth0/callback", func(c echo.Context) error {
		if auth0OAuth2Config == nil || auth0Verifier == nil {
			return c.String(http.StatusInternalServerError, "Auth0 no está configurado")
		}
		ctx := c.Request().Context()
		code := c.QueryParam("code")
		if code == "" {
			return c.String(http.StatusBadRequest, "No code param")
		}
		oauth2Token, err := auth0OAuth2Config.Exchange(ctx, code)
		if err != nil {
			return c.String(http.StatusInternalServerError, "Error intercambiando código: "+err.Error())
		}
		rawIDToken, ok := oauth2Token.Extra("id_token").(string)
		if !ok {
			return c.String(http.StatusInternalServerError, "No se recibió id_token")
		}
		idToken, err := auth0Verifier.Verify(ctx, rawIDToken)
		if err != nil {
			return c.String(http.StatusUnauthorized, "Token inválido: "+err.Error())
		}
		// Extraer claims
		var claims map[string]interface{}
		if err := idToken.Claims(&claims); err != nil {
			return c.String(http.StatusInternalServerError, "Error leyendo claims: "+err.Error())
		}
		// Redirigir al frontend con el id_token como parámetro
		redirectUrl := "http://localhost:8080/#/todos?id_token=" + rawIDToken
		return c.Redirect(http.StatusTemporaryRedirect, redirectUrl)
	})

	// Start server
	e.Logger.Fatal(e.Start(hostport))
}

type LoginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

func getLoginHandler(userService UserService) echo.HandlerFunc {
	f := func(c echo.Context) error {
		requestData := LoginRequest{}
		decoder := json.NewDecoder(c.Request().Body)
		if err := decoder.Decode(&requestData); err != nil {
			log.Printf("could not read credentials from POST body: %s", err.Error())
			return ErrHttpGenericMessage
		}

		ctx := c.Request().Context()
		user, err := userService.Login(ctx, requestData.Username, requestData.Password)
		if err != nil {
			if err != ErrWrongCredentials {
				log.Printf("could not authorize user '%s': %s", requestData.Username, err.Error())
				return ErrHttpGenericMessage
			}

			return ErrWrongCredentials
		}
		token := jwt.New(jwt.SigningMethodHS256)

		// Set claims
		claims := token.Claims.(jwt.MapClaims)
		claims["username"] = user.Username
		claims["firstname"] = user.FirstName
		claims["lastname"] = user.LastName
		claims["role"] = user.Role
		claims["exp"] = time.Now().Add(time.Hour * 72).Unix()

		// Generate encoded token and send it as response.
		t, err := token.SignedString([]byte(jwtSecret))
		if err != nil {
			log.Printf("could not generate a JWT token: %s", err.Error())
			return ErrHttpGenericMessage
		}

		return c.JSON(http.StatusOK, map[string]string{
			"accessToken": t,
		})
	}

	return echo.HandlerFunc(f)
}
