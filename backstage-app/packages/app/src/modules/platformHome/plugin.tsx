import {
  PageBlueprint,
  createFrontendPlugin,
} from '@backstage/frontend-plugin-api';
import HomeIcon from '@material-ui/icons/Home';

export const homePage = PageBlueprint.make({
  name: 'platform-home',
  params: {
    path: '/',
    title: 'Platform Home',
    icon: <HomeIcon />,
    loader: () =>
      import('./PlatformHomePage').then(m => <m.PlatformHomePage />),
  },
});

export const platformHomePlugin = createFrontendPlugin({
  pluginId: 'platform-home',
  extensions: [homePage],
});
