import {
  PageBlueprint,
  createFrontendPlugin,
} from '@backstage/frontend-plugin-api';
import StorefrontIcon from '@material-ui/icons/Storefront';

export const shopPage = PageBlueprint.make({
  name: 'shop',
  params: {
    path: '/shop',
    title: 'Shop',
    icon: <StorefrontIcon />,
    loader: () =>
      import('./SampleProductsPage').then(m => <m.SampleProductsPage />),
  },
});

export const sampleProductsPlugin = createFrontendPlugin({
  pluginId: 'sample-products',
  extensions: [shopPage],
});
