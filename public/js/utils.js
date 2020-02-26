// To strip tags from input
function stripTags(string="") {
    return string.replace(/(<([^>]+)>)/ig, '').trim();
}
