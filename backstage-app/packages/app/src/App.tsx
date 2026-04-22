import { createApp } from '@backstage/frontend-defaults';
import catalogPlugin from '@backstage/plugin-catalog/alpha';
import { navModule } from './modules/nav';
import { platformHomePlugin } from './modules/platformHome';

export default createApp({
  features: [catalogPlugin, navModule, platformHomePlugin],
});
