const { Octokit } = require("@octokit/rest");
const { paginateRest } = require("@octokit/plugin-paginate-rest");
const { throttling } = require("@octokit/plugin-throttling");

const MyOctokit = Octokit.plugin(paginateRest, throttling);

const octokit = new MyOctokit({
  auth: process.env.GITHUB_TOKEN,
  throttle: {
    onRateLimit: (retryAfter, options) => {
      console.warn(`Request quota exhausted for request ${options.method} ${options.url}`);
      if (options.request.retryCount === 0) {
        console.log(`Retrying after ${retryAfter} seconds!`);
        return true;
      }
    },
    onAbuseLimit: (retryAfter, options) => {
      console.warn(`Abuse detected for request ${options.method} ${options.url}`);
    },
  },
});

const owner = "CircuitVerse";
const repo = "CircuitVerse";
const labelNeedsTriage = "needs triage";
const labelVerified = "verified";
const labelDuplicate = "duplicate";
const labelNeedsMoreInfo = "needs more info";
const labelWontFix = "wontfix";
const validReaction = "👍";
const duplicateReaction = "👎";
const needsMoreInfoReaction = "❓";
const wontFixReaction = "🚫";
const voteThreshold = 5;

async function fetchIssues() {
  const issues = await octokit.paginate(octokit.issues.listForRepo, {
    owner,
    repo,
    labels: labelNeedsTriage,
    state: "open",
  });
  return issues;
}

async function countVotes(issue) {
  const reactions = await octokit.reactions.listForIssue({
    owner,
    repo,
    issue_number: issue.number,
  });

  const voteCounts = {
    valid: 0,
    duplicate: 0,
    needsMoreInfo: 0,
    wontFix: 0,
  };

  reactions.data.forEach((reaction) => {
    switch (reaction.content) {
      case validReaction:
        voteCounts.valid++;
        break;
      case duplicateReaction:
        voteCounts.duplicate++;
        break;
      case needsMoreInfoReaction:
        voteCounts.needsMoreInfo++;
        break;
      case wontFixReaction:
        voteCounts.wontFix++;
        break;
    }
  });

  return voteCounts;
}

async function updateIssueLabels(issue, voteCounts) {
  let newLabel = null;

  if (voteCounts.valid >= voteThreshold) {
    newLabel = labelVerified;
  } else if (voteCounts.duplicate >= voteThreshold) {
    newLabel = labelDuplicate;
  } else if (voteCounts.needsMoreInfo >= voteThreshold) {
    newLabel = labelNeedsMoreInfo;
  } else if (voteCounts.wontFix >= voteThreshold) {
    newLabel = labelWontFix;
  }

  if (newLabel) {
    await octokit.issues.update({
      owner,
      repo,
      issue_number: issue.number,
      labels: [newLabel],
    });

    await octokit.issues.createComment({
      owner,
      repo,
      issue_number: issue.number,
      body: `This issue has been updated with the "${newLabel}" label based on community votes.`,
    });
  }
}

async function verifyIssues() {
  const issues = await fetchIssues();

  for (const issue of issues) {
    const voteCounts = await countVotes(issue);
    await updateIssueLabels(issue, voteCounts);
  }
}

verifyIssues().catch((error) => {
  console.error(error);
  process.exit(1);
});
