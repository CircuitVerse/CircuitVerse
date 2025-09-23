import React from 'react';
import clsx from 'clsx';
import styles from './HomepageFeatures.module.css';

const FeatureList = [
  {
    title: 'Test across modern browsers',
    Svg: require('../../static/img/undraw_windows.svg').default,
    description: (
      <>
        Provide browser automation for Chrome, MS Edge, Firefox, and WebKit.
      </>
    ),
  },
  {
    title: 'Make more reliable tests',
    Svg: require('../../static/img/undraw_dropdown_menu.svg').default,
    description: (
      <>
        Automate with JavaScript-based Playwright protocol, which precisely wait for elements.
      </>
    ),
  },
  {
    title: 'Work with Ruby on Rails',
    Svg: require('../../static/img/undraw_web_development.svg').default,
    description: (
      <>
        Keep your existing system specs for Rails. Just use <a href="https://rubygems.org/gems/capybara-playwright-driver">capybara-playwright-driver</a>.
      </>
    ),
  },
];

function Feature({ Svg, title, description }) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <Svg className={styles.featureSvg} alt={title} />
      </div>
      <div className="text--center padding-horiz--md">
        <h3>{title}</h3>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
