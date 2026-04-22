import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import swaggerUi from 'swagger-ui-express';
import { router } from './routes';
import { errorMiddleware } from './middlewares/error.middleware';
import { swaggerSpec } from './swagger/swagger';

const app: Application = express();

app.use(helmet());
app.use(cors());
// eslint-disable-next-line @typescript-eslint/no-explicit-any
app.use(compression() as any);
app.use(morgan('dev'));
app.use(express.json({ limit: '50kb' }));
app.use(express.urlencoded({ extended: true, limit: '50kb' }));

// eslint-disable-next-line @typescript-eslint/no-explicit-any
app.use('/api-docs', swaggerUi.serve as any, swaggerUi.setup(swaggerSpec) as any);
app.use('/api', router);

app.use(errorMiddleware);

export { app };
