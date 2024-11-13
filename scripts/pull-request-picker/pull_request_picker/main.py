import os
import sys
import random
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta, SU, SA
from dotenv import load_dotenv
from github import Github, GithubException

# --------- Configuration ---------

load_dotenv()

# GitHub Personal Access Token (ensure it has repo and read:org access)
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")

# GitHub Organization and Team Configuration
ORGANIZATION = os.getenv("GITHUB_ORGANIZATION")
TEAM_SLUG = os.getenv("GITHUB_TEAM_SLUG")
# Alternatively, you can use TEAM_ID if you prefer (see note below)

# Repository to search PRs in (owner/repo). If multiple, make this a list
REPOSITORIES = (
    os.getenv("GITHUB_REPOSITORIES").split(",")
    if os.getenv("GITHUB_REPOSITORIES")
    else []
)

# Number of PRs to select randomly for review
NUMBER_OF_PRS_TO_SELECT = int(os.getenv("NUMBER_OF_PRS", "5"))

# --------- End of Configuration ---------


def get_last_week_date_range():
    """
    Returns the start and end datetime objects for the last week (Sunday to Saturday).
    """
    today = datetime.utcnow()
    # Find last Sunday
    last_sunday = today + relativedelta(weekday=SU(-1))
    # Last week's Sunday
    last_sunday = last_sunday - timedelta(weeks=1)
    # Last week's Saturday
    last_saturday = last_sunday + timedelta(days=6)

    # Normalize to midnight UTC for start and end of the week
    start_date = datetime(last_sunday.year, last_sunday.month, last_sunday.day)
    end_date = datetime(
        last_saturday.year, last_saturday.month, last_saturday.day, 23, 59, 59
    )

    return start_date, end_date


def fetch_team_members(g, org_name, team_slug):
    """
    Fetches all members of a specified team within an organization.
    """
    try:
        org = g.get_organization(org_name)
    except GithubException as e:
        print(f"Error accessing organization '{org_name}': {e}")
        sys.exit(1)

    try:
        team = org.get_team_by_slug(team_slug)
    except GithubException as e:
        print(f"Error accessing team '{team_slug}' in organization '{org_name}': {e}")
        sys.exit(1)

    try:
        members = team.get_members()
        member_logins = [member.login for member in members]
        print(f"Retrieved {len(member_logins)} member(s) from team '{team_slug}'.")
        return member_logins
    except GithubException as e:
        print(f"Error fetching members of team '{team_slug}': {e}")
        sys.exit(1)


def fetch_prs(g, repo_name, users, start_date, end_date):
    """
    Fetches PRs from the specified repository, created between start_date and end_date by specified users.
    """
    try:
        repo = g.get_repo(repo_name)
    except GithubException as e:
        print(f"Error accessing repository '{repo_name}': {e}")
        return []

    query = f"is:pr repo:{repo_name} created:{start_date.strftime('%Y-%m-%d')}..{end_date.strftime('%Y-%m-%d')}"

    try:
        prs = g.search_issues(query=query, sort="created", order="desc")
    except GithubException as e:
        print(f"Error searching PRs in repository '{repo_name}': {e}")
        return []

    # Filter PRs by target users
    filtered_prs = [pr for pr in prs if pr.user is not None and pr.user.login in users]

    print(
        f"Found {len(filtered_prs)} PR(s) in '{repo_name}' from specified team members."
    )
    return filtered_prs


def select_random_prs(prs, number):
    """
    Selects a specified number of PRs randomly from the list.
    """
    if len(prs) < number:
        print(f"Only {len(prs)} PR(s) available. Selecting all.")
        return prs
    return random.sample(prs, number)


def main():
    # Initialize GitHub client
    if not GITHUB_TOKEN:
        print(
            "Error: GitHub token not set. Please set the GITHUB_TOKEN environment variable."
        )
        sys.exit(1)

    g = Github(GITHUB_TOKEN)

    # Get date range for last week
    start_date, end_date = get_last_week_date_range()
    print(
        f"Fetching PRs created between {start_date.strftime('%Y-%m-%d')} and {end_date.strftime('%Y-%m-%d')}"
    )

    # Fetch team members
    target_users = fetch_team_members(g, ORGANIZATION, TEAM_SLUG)
    if not target_users:
        print("No team members found. Exiting.")
        sys.exit(0)

    all_filtered_prs = []

    # Fetch PRs from all specified repositories
    for repo in REPOSITORIES:
        prs = fetch_prs(g, repo, target_users, start_date, end_date)
        all_filtered_prs.extend(prs)

    print(f"\nTotal PRs found from all repositories: {len(all_filtered_prs)}")

    if not all_filtered_prs:
        print("No PRs found for the specified criteria.")
        sys.exit(0)

    # Select random PRs
    selected_prs = select_random_prs(all_filtered_prs, NUMBER_OF_PRS_TO_SELECT)
    print(f"\nSelected {len(selected_prs)} PR(s) for review:")
    for pr in selected_prs:
        print(
            f"- [{pr.repository.full_name}] #{pr.number} {pr.title} by {pr.user.login} ({pr.html_url})"
        )


if __name__ == "__main__":
    main()
