export function sanitizeLabel(name) {
  //        return name.replace(/ Inverse/g, "_inv").replace(/ /g , "_");
  var temp = name;
  // if there is a space anywhere but the last place
  // replace spaces by "_"
  // last space is required for escaped id
  if (temp.search(/ /g) < temp.length - 1 && temp.search(/ /g) >= 0) {
    temp = temp.replace(/ Inverse/g, '_inv');
    temp = temp.replace(/ /g, '_');
  }
  // if first character is not \ already
  if (temp.substring(0, 1).search(/\\/g) < 0) {
    // if there are non-alphanum_ character, or first character is num, add \
    if (temp.search(/[\W]/g) > -1 || temp.substring(0, 1).search(/[0-9]/g) > -1)
      temp = '\\' + temp + ' ';
  }
  return temp;
}

export function generateNodeName(node, currentCount, totalCount) {
  if (node.verilogLabel) return node.verilogLabel;
  var parentVerilogLabel = node.parent.verilogLabel;
  var nodeName;
  if (node.label) {
    nodeName = sanitizeLabel(node.label);
  } else {
    nodeName = (totalCount > 1) ? 'out_' + currentCount : 'out';
  }
  if (parentVerilogLabel.substring(0, 1).search(/\\/g) < 0)
    return (parentVerilogLabel) + '_' + nodeName;
  else
    return (parentVerilogLabel.substring(0, parentVerilogLabel.length - 1)) +
        '_' + nodeName + ' ';
}