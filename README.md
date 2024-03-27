<div align="center">
  <img src="https://github.com/CircuitVerse/CircuitVerse/raw/master/app/assets/images/cvlogo.svg" alt="The CircuitVerse logo" width="400"/>
</div>

# CircuitVerse Frontend Vue
[CircuitVerse Frontend Vue](https://circuitverse.netlify.app/simulatorvue) is dedicated to enhancing the CircuitVerse platform in several key ways. Our primary focus is on decoupling the [CircuitVerse Simulator](https://circuitverse.org/simulator) from the backend, allowing it to function independently and with greater flexibility. Additionally, we're working to remove the reliance on jQueryUI, opting for cleaner and more contemporary code practices. To improve performance and code readability, we're transitioning from traditional DOM mutations to string-based manipulation. Furthermore, we're actively integrating internationalization features to ensure the platform is accessible to users worldwide. In summary, our repository aims to elevate the capabilities and user experience of CircuitVerse through targeted improvements and optimizations.

## Community
We would love to hear from you! We communicate on Slack:

[![Slack](https://img.shields.io/badge/chat-on_slack-purple.svg?style=for-the-badge&logo=slack)](https://join.slack.com/t/circuitverse-team/shared_invite/zt-p6bgler9-~8vWvsKmL9lZeYg4pP9hwQ)

## Installation
To set up the project on your local machine, follow these steps:

  1. Clone the repository to your local machine using the following command:
  ```
  git clone https://github.com/CircuitVerse/cv-frontend-vue.git
  ```
  2. Navigate to the project directory:
  ```
  cd cv-frontend-vue
  ```
  3. Install the project dependencies:
  ```
  npm install
  ```
  4. Start the development server:
  ```
  npm run dev
  ```

## Setting up on cloud with Stackblitz
[StackBlitz](https://developer.stackblitz.com/guides/user-guide/what-is-stackblitz) is an instant fullstack web IDE for the JavaScript ecosystem.

  1. Initiate the setup process by clicking on the following button:

  [![Open in StackBlitz](https://developer.stackblitz.com/img/open_in_stackblitz.svg)](https://stackblitz.com/~/github.com/CircuitVerse/cv-frontend-vue)

  2. Once the setup is complete, a Preview URL will be displayed in the browser window. Append `/simulatorvue/` to your URL to access the simulator.
  ```
  https://<preview_url>/simulatorvue/
  ```

## How to Use Vue Simulator with CircuitVerse Main Repo
To access the Vue Simulator from the [CircuitVerse main repo](https://github.com/CircuitVerse/CircuitVerse) dev server, you can follow one of the following methods:

### Accessing Vue Simulator
  1. Start the CircuitVerse Main Repo dev server.
  2. go to the `/vuesimulator` path in the dev server.
  3. You would be accessing the Vue Simulator.

### Setting Vue Simulator as Default
  1. Log in to the CircuitVerse dev server using the admin account:
      - **Email:** `admin@circuitverse.org`
      - **Password:** `password`
  2. Once logged in, go to `/flipper` path and turn on vuesim feature flag site wide or for your user.
  3. After activation, you will be able to access the Vue Simulator site-wide in your dev server, also in `/simulator` path the Vue Simulator will be opening instead of the old simulator.

## Code of Conduct
We follow the [Code of Conduct](https://github.com/CircuitVerse/CircuitVerse/blob/master/code-of-conduct.md) of the [CircuitVerse](https://circuitverse.org) Community.

## Contributing
See [`CONTRIBUTING.md`](https://github.com/CircuitVerse/CircuitVerse/blob/master/CONTRIBUTING.md) for more information on contributing to CircuitVerse.

## License
This project is licensed under the [MIT License](LICENSE).

## To Dos -
1. **Creating the mobile version of the vue simulator** 
2. **Testing and bug fixing**
3. **Typescript integration & style Refactoring**
4. **Creating the desktop application** 
5. **Removing JQuery**
