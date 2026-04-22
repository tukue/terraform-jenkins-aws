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
import ExtensionIcon from '@material-ui/icons/Extension';
import LibraryBooksIcon from '@material-ui/icons/LibraryBooks';
import PlayCircleOutlineIcon from '@material-ui/icons/PlayCircleOutline';

const useStyles = makeStyles(theme => ({
  page: {
    minHeight: '100%',
    background:
      'linear-gradient(180deg, rgba(15, 23, 42, 0.04) 0%, rgba(15, 23, 42, 0) 24%)',
    paddingTop: theme.spacing(4),
    paddingBottom: theme.spacing(6),
  },
  hero: {
    padding: theme.spacing(5),
    borderRadius: 24,
    background:
      'linear-gradient(140deg, #0f172a 0%, #1d4ed8 52%, #0ea5e9 100%)',
    color: theme.palette.common.white,
    boxShadow: '0 24px 60px rgba(15, 23, 42, 0.22)',
  },
  eyebrow: {
    marginBottom: theme.spacing(2),
    backgroundColor: 'rgba(255, 255, 255, 0.14)',
    color: theme.palette.common.white,
    fontWeight: 600,
  },
  heroActions: {
    display: 'flex',
    flexWrap: 'wrap',
    gap: theme.spacing(2),
    marginTop: theme.spacing(4),
  },
  actionLink: {
    textDecoration: 'none',
  },
  section: {
    marginTop: theme.spacing(4),
  },
  card: {
    height: '100%',
    padding: theme.spacing(3),
    borderRadius: 20,
    border: `1px solid ${theme.palette.divider}`,
    boxShadow: 'none',
  },
  cardIcon: {
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    width: 44,
    height: 44,
    borderRadius: 14,
    marginBottom: theme.spacing(2),
    backgroundColor: theme.palette.primary.main,
    color: theme.palette.common.white,
  },
  metric: {
    padding: theme.spacing(3),
    borderRadius: 18,
    border: `1px solid ${theme.palette.divider}`,
    backgroundColor: theme.palette.background.paper,
    boxShadow: 'none',
  },
  steps: {
    margin: 0,
    paddingLeft: theme.spacing(2.5),
    '& li': {
      marginBottom: theme.spacing(1.5),
    },
  },
  inlineLink: {
    display: 'inline-flex',
    alignItems: 'center',
    gap: theme.spacing(1),
    fontWeight: 600,
    marginTop: theme.spacing(2),
  },
}));

const products = [
  {
    title: 'Jenkins on AWS',
    icon: <BuildIcon />,
    summary:
      'Standardized CI/CD infrastructure with reusable Terraform, environment-aware configuration, and operational runbooks.',
    href: '/catalog/default/component/terraform-jenkins-module',
    cta: 'View Jenkins product',
  },
  {
    title: 'Customer ECS Runtime',
    icon: <CloudQueueIcon />,
    summary:
      'Repeatable customer runtime baseline for multi-environment SaaS workloads with a controlled runtime contract.',
    href: '/catalog/default/component/customer-ecs-runtime-product',
    cta: 'View ECS product',
  },
  {
    title: 'Standard Service Deployment',
    icon: <ExtensionIcon />,
    summary:
      'Template-driven service bootstrap path that packages platform tiers and repository generation into one flow.',
    href: '/create',
    cta: 'Launch self-service',
  },
];

const operatingLenses = [
  'Backstage is the entry point for self-service templates and platform discovery.',
  'Terraform modules stay shared and reusable; product-level changes should be reviewed as platform changes.',
  'The supported promotion model remains aligned to dev, qa, and prod configuration sets.',
  'Local evaluation is supported first so the platform story can be reviewed before AWS-backed applies.',
];

export const PlatformHomePage = () => {
  const classes = useStyles();

  return (
    <Box className={classes.page}>
      <Container maxWidth="lg">
        <Paper className={classes.hero}>
          <Chip label="Platform Product Portal" className={classes.eyebrow} />
          <Typography variant="h3" component="h1" gutterBottom>
            Productized infrastructure, not a loose pile of Terraform.
          </Typography>
          <Typography variant="h6">
            This portal packages the repository into supported platform paths for
            Jenkins, customer ECS runtimes, and standard service delivery. Use
            the catalog to inspect the system, then use scaffolder templates to
            stay on the supported golden paths.
          </Typography>
          <div className={classes.heroActions}>
            <Link to="/create" className={classes.actionLink}>
              <Button
                variant="contained"
                color="secondary"
                endIcon={<ArrowForwardIcon />}
              >
                Start Self-Service
              </Button>
            </Link>
            <Link
              to="/catalog/default/system/internal-developer-platform"
              className={classes.actionLink}
            >
              <Button
                variant="outlined"
                style={{ color: '#fff', borderColor: 'rgba(255,255,255,0.45)' }}
              >
                Open Platform System
              </Button>
            </Link>
          </div>
        </Paper>

        <Grid container spacing={3} className={classes.section}>
          <Grid item xs={12} md={4}>
            <Paper className={classes.metric}>
              <Typography variant="overline" color="textSecondary">
                Supported Products
              </Typography>
              <Typography variant="h4">3</Typography>
              <Typography variant="body2" color="textSecondary">
                Jenkins, ECS runtime, and standard service paths are the
                supported product surface in this repo.
              </Typography>
            </Paper>
          </Grid>
          <Grid item xs={12} md={4}>
            <Paper className={classes.metric}>
              <Typography variant="overline" color="textSecondary">
                Delivery Environments
              </Typography>
              <Typography variant="h4">dev / qa / prod</Typography>
              <Typography variant="body2" color="textSecondary">
                The platform contract is built around visible promotion across
                environment-specific configuration.
              </Typography>
            </Paper>
          </Grid>
          <Grid item xs={12} md={4}>
            <Paper className={classes.metric}>
              <Typography variant="overline" color="textSecondary">
                Entry Points
              </Typography>
              <Typography variant="h4">Catalog + Create</Typography>
              <Typography variant="body2" color="textSecondary">
                Browse the platform model in the catalog, then use scaffolder
                templates for the supported self-service paths.
              </Typography>
            </Paper>
          </Grid>
        </Grid>

        <Box className={classes.section}>
          <Typography variant="h4" gutterBottom>
            Supported platform products
          </Typography>
          <Typography variant="body1" color="textSecondary" paragraph>
            These are the product tracks the repository is organized around.
            Each one is intended to be understandable, reusable, and supportable
            as a platform offering.
          </Typography>
          <Grid container spacing={3}>
            {products.map(product => (
              <Grid item xs={12} md={4} key={product.title}>
                <Paper className={classes.card}>
                  <div className={classes.cardIcon}>{product.icon}</div>
                  <Typography variant="h5" gutterBottom>
                    {product.title}
                  </Typography>
                  <Typography variant="body2" color="textSecondary">
                    {product.summary}
                  </Typography>
                  <Link to={product.href} className={classes.inlineLink}>
                    {product.cta}
                    <ArrowForwardIcon fontSize="small" />
                  </Link>
                </Paper>
              </Grid>
            ))}
          </Grid>
        </Box>

        <Grid container spacing={3} className={classes.section}>
          <Grid item xs={12} md={7}>
            <Paper className={classes.card}>
              <div className={classes.cardIcon}>
                <PlayCircleOutlineIcon />
              </div>
              <Typography variant="h5" gutterBottom>
                Golden path flow
              </Typography>
              <ol className={classes.steps}>
                <li>Choose the correct product path from the catalog or create flow.</li>
                <li>Use the standard template or reusable module instead of starting from scratch.</li>
                <li>Review the generated infrastructure definition against platform guardrails.</li>
                <li>Keep configuration aligned to dev, qa, and prod promotion patterns.</li>
                <li>Treat exceptions as explicit platform changes, not silent one-off drift.</li>
              </ol>
              <Link
                to="/catalog/default/component/platform-product-foundation"
                className={classes.inlineLink}
              >
                Inspect the product foundation
                <ArrowForwardIcon fontSize="small" />
              </Link>
            </Paper>
          </Grid>
          <Grid item xs={12} md={5}>
            <Paper className={classes.card}>
              <div className={classes.cardIcon}>
                <LibraryBooksIcon />
              </div>
              <Typography variant="h5" gutterBottom>
                Operating model
              </Typography>
              {operatingLenses.map(item => (
                <Typography
                  key={item}
                  variant="body2"
                  color="textSecondary"
                  paragraph
                >
                  {item}
                </Typography>
              ))}
              <Link to="/catalog" className={classes.inlineLink}>
                Browse the full catalog
                <ArrowForwardIcon fontSize="small" />
              </Link>
            </Paper>
          </Grid>
        </Grid>
      </Container>
    </Box>
  );
};
