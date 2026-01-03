export default function paramsFieldComponent() {
  return {
    get isNarrowLayout() {
      return this.narrow || false;
    },
  };
}
