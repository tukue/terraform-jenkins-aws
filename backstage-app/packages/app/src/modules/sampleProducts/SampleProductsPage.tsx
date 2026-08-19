import { Link } from '@backstage/core-components';
import {
  Box,
  Button,
  Chip,
  Container,
  Grid,
  Paper,
  Typography,
  makeStyles,
} from '@material-ui/core';
import ArrowForwardIcon from '@material-ui/icons/ArrowForward';
import BuildIcon from '@material-ui/icons/Build';
import CloudQueueIcon from '@material-ui/icons/CloudQueue';
import StorageIcon from '@material-ui/icons/Storage';

const useStyles = makeStyles(theme => ({
  page: {
    minHeight: '100%',
    paddingTop: theme.spacing(4),
    paddingBottom: theme.spacing(6),
    background:
      'linear-gradient(180deg, rgba(2, 132, 199, 0.08) 0%, rgba(255, 255, 255, 0) 28%)',
  },
  header: {
    marginBottom: theme.spacing(4),
  },
  eyebrow: {
    marginBottom: theme.spacing(2),
    fontWeight: 600,
  },
  card: {
    height: '100%',
    padding: theme.spacing(3),
    borderRadius: 16,
    border: `1px solid ${theme.palette.divider}`,
    boxShadow: 'none',
    display: 'flex',
    flexDirection: 'column',
  },
  cardHeader: {
    display: 'flex',
    gap: theme.spacing(2),
    alignItems: 'flex-start',
    marginBottom: theme.spacing(2),
  },
  cardIcon: {
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    width: 44,
    height: 44,
    borderRadius: 12,
    backgroundColor: theme.palette.primary.main,
    color: theme.palette.common.white,
    flexShrink: 0,
  },
  tags: {
    display: 'flex',
    flexWrap: 'wrap',
    gap: theme.spacing(1),
    marginTop: theme.spacing(2),
    marginBottom: theme.spacing(3),
  },
  cardActions: {
    marginTop: 'auto',
    display: 'flex',
    flexWrap: 'wrap',
    gap: theme.spacing(1.5),
  },
  link: {
    textDecoration: 'none',
  },
}));

const sampleProducts = [
  {
    title: 'Jenkins CI/CD Platform',
    category: 'Delivery',
    description:
      'Provision a standard Jenkins runtime with Terraform modules, environment promotion, and operational runbooks.',
    icon: <BuildIcon />,
    tags: ['jenkins', 'ec2', 'delivery'],
    catalogPath: '/catalog/default/component/terraform-jenkins-module',
    createPath: '/create',
  },
  {
    title: 'Customer ECS Runtime',
    category: 'Runtime',
    description:
      'Bootstrap a customer-facing ECS service runtime with image delivery, WAF-ready ingress, and environment defaults.',
    icon: <CloudQueueIcon />,
    tags: ['ecs', 'runtime', 'tenant'],
    catalogPath: '/catalog/default/component/customer-ecs-runtime-product',
    createPath: '/create',
  },
  {
    title: 'Secure S3 Bucket',
    category: 'Storage',
    description:
      'Create an encrypted, tagged S3 bucket with public access blocked, versioning, and lifecycle controls.',
    icon: <StorageIcon />,
    tags: ['s3', 'storage', 'baseline'],
    catalogPath: '/catalog/default/resource/terraform-state-s3-backend',
    createPath: '/create',
  },
];

export const SampleProductsPage = () => {
  const classes = useStyles();

  return (
    <Box className={classes.page}>
      <Container maxWidth="lg">
        <Box className={classes.header}>
          <Chip label="Sample Products" className={classes.eyebrow} />
          <Typography variant="h3" component="h1" gutterBottom>
            Shop platform products
          </Typography>
          <Typography variant="h6" color="textSecondary">
            Start from sample platform products that are available without
            calling an external products API.
          </Typography>
        </Box>

        <Grid container spacing={3}>
          {sampleProducts.map(product => (
            <Grid item xs={12} md={4} key={product.title}>
              <Paper className={classes.card}>
                <div className={classes.cardHeader}>
                  <div className={classes.cardIcon}>{product.icon}</div>
                  <div>
                    <Typography variant="overline" color="textSecondary">
                      {product.category}
                    </Typography>
                    <Typography variant="h5">{product.title}</Typography>
                  </div>
                </div>
                <Typography variant="body2" color="textSecondary">
                  {product.description}
                </Typography>
                <div className={classes.tags}>
                  {product.tags.map(tag => (
                    <Chip key={tag} label={tag} size="small" />
                  ))}
                </div>
                <div className={classes.cardActions}>
                  <Link to={product.createPath} className={classes.link}>
                    <Button
                      variant="contained"
                      color="primary"
                      endIcon={<ArrowForwardIcon />}
                    >
                      Create
                    </Button>
                  </Link>
                  <Link to={product.catalogPath} className={classes.link}>
                    <Button variant="outlined">View catalog</Button>
                  </Link>
                </div>
              </Paper>
            </Grid>
          ))}
        </Grid>
      </Container>
    </Box>
  );
};
