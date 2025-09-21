'use strict';
const cache = require('memory-cache');
const {Annotation, 
    jsonEncoder: {JSON_V2}} = require('zipkin');

const OPERATION_CREATE = 'CREATE',
      OPERATION_DELETE = 'DELETE';

class TodoController {
    constructor({tracer, redisClient, logChannel}) {
        this._tracer = tracer;
        // Promisify the redis get and setex methods
        this._redisClient = {
            get: (key) => new Promise((resolve, reject) => {
                redisClient.get(key, (err, reply) => {
                    if (err) reject(err);
                    else resolve(reply);
                });
            }),
            setex: (key, ttl, value) => new Promise((resolve, reject) => {
                redisClient.setex(key, ttl, value, (err, reply) => {
                    if (err) reject(err);
                    else resolve(reply);
                });
            })
        };
        // Keep the original client for publish operations
        this._redisPublisher = redisClient;
        this._logChannel = logChannel;
    }

    // TODO: these methods are not concurrent-safe
    async list (req, res) {
        try {
            const data = await this._getTodoData(req.user.username);
            res.json(data.items);
        } catch (err) {
            console.error('Error fetching todo list:', err);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    async create (req, res) {
        try {
            const data = await this._getTodoData(req.user.username);
            const todo = {
                content: req.body.content,
                id: data.lastInsertedID
            };
            data.items[data.lastInsertedID] = todo;

            data.lastInsertedID++;
            await this._setTodoData(req.user.username, data);

            this._logOperation(OPERATION_CREATE, req.user.username, todo.id);

            res.json(todo);
        } catch (err) {
            console.error('Error creating todo:', err);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    async delete (req, res) {
        try {
            const data = await this._getTodoData(req.user.username);
            const id = req.params.taskId;
            delete data.items[id];
            await this._setTodoData(req.user.username, data);

            this._logOperation(OPERATION_DELETE, req.user.username, id);

            res.status(204).send();
        } catch (err) {
            console.error('Error deleting todo:', err);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    _logOperation (opName, username, todoId) {
        this._tracer.scoped(() => {
            const traceId = this._tracer.id;
            this._redisPublisher.publish(this._logChannel, JSON.stringify({
                zipkinSpan: traceId,
                opName: opName,
                username: username,
                todoId: todoId,
            }))
        })
    }

    async _getTodoData (userID) {
        // Try to get data from Redis cache first
        try {
            const cachedData = await this._redisClient.get(`todos:${userID}`);
            if (cachedData) {
                return JSON.parse(cachedData);
            }
        } catch (err) {
            console.error('Redis cache read error:', err);
        }

        // If cache miss or error, return default data
        const data = {
            items: {
                '1': {
                    id: 1,
                    content: "Create new todo",
                },
                '2': {
                    id: 2,
                    content: "Update me",
                },
                '3': {
                    id: 3,
                    content: "Delete example ones",
                }
            },
            lastInsertedID: 3
        };

        // Store in cache for future requests
        await this._setTodoData(userID, data);
        return data;
    }

    async _setTodoData (userID, data) {
        try {
            // Cache for 1 hour (3600 seconds)
            await this._redisClient.setex(`todos:${userID}`, 3600, JSON.stringify(data));
        } catch (err) {
            console.error('Redis cache write error:', err);
        }
    }
}

module.exports = TodoController