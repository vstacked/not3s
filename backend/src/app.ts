import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import { router } from './routes';
import { errorMiddleware } from './middlewares/error.middleware';

const app: Application = express();

app.use(helmet());
app.use(cors());
// eslint-disable-next-line @typescript-eslint/no-explicit-any
app.use(compression() as any);
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/api', router);

app.use(errorMiddleware);

export { app };
