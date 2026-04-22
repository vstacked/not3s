import swaggerJsdoc from 'swagger-jsdoc';

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'not3s API',
      version: '1.0.0',
      description: 'REST API for the not3s note-taking app',
    },
    servers: [{ url: '/api', description: 'API server' }],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
      schemas: {
        MessageResponse: {
          type: 'object',
          properties: {
            message: { type: 'string', example: 'Operation successful' },
          },
        },
        ErrorResponse: {
          type: 'object',
          properties: {
            error: { type: 'string', example: 'A user-friendly error message' },
          },
        },
        Note: {
          type: 'object',
          properties: {
            id: { type: 'integer', example: 1 },
            title: { type: 'string', example: 'My note' },
            content: { type: 'string', example: 'Note content here' },
          },
        },
        NoteInput: {
          type: 'object',
          required: ['title', 'content'],
          properties: {
            title: { type: 'string', example: 'My note' },
            content: { type: 'string', example: 'Note content here' },
          },
        },
      },
      responses: {
        Error: {
          description: 'Error response',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/ErrorResponse' },
            },
          },
        },
      },
    },
  },
  apis: ['./src/routes/*.ts'],
};

export const swaggerSpec = swaggerJsdoc(options);
