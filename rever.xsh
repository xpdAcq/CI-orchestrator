$PROJECT = 'orch'
$ACTIVITIES = ['version_bump', 'changelog', 'tag', 'push_tag', 'ghrelease',
               'conda_forge']

$VERSION_BUMP_PATTERNS = [
    ('{}/__init__.py'.format($PROJECT), '__version__\s*=.*', "__version__ = '$VERSION'"),
    ('setup.py', 'version\s*=.*,', "version='$VERSION',")
    ]
$CHANGELOG_FILENAME = 'CHANGELOG.rst'
$CHANGELOG_IGNORE = ['TEMPLATE.rst']
$PUSH_TAG_REMOTE = 'git@github.com:xpdAcq/CI-orchestrator.git'

$GITHUB_ORG = 'xpdAcq'
$GITHUB_REPO = 'CI-orchestrator'
