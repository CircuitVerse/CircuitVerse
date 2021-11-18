const config = require('./' + process.env.NODE_ENV);

export default class Environment {
  static get ACTION_CABLE_CONNECTION_URL() {
    return config.ACTION_CABLE_CONNECTION_URL;
  }
}