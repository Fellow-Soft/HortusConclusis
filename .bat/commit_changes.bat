@echo off
echo Staging and committing project reorganization changes...

REM Initialize git repository if not already initialized
if not exist ".git" (
    git init
    echo Initialized new git repository
)

REM Add all files to staging
git add .

REM Create commit with detailed message
git commit -m "Project Reorganization and Code Refactoring

1. Directory Structure Improvements:
- Created MD/ directory for documentation
- Created .bat/ directory for batch files
- Organized scripts into functional modules

2. Code Refactoring:
- Standardized naming conventions (removed enhanced/complete suffixes)
- Consolidated helper functions into main classes
- Created common utilities class in scripts/core

3. Documentation Updates:
- Updated reference mapping with new file locations
- Created CHANGELOG.md for version tracking
- Updated project structure documentation

4. Archive Management:
- Moved redundant files to archive with preserved structure
- Created reference mapping for archived files
- Maintained backup of original files"

echo.
echo Changes have been staged and committed.
echo You can now push these changes to the remote repository.
echo.
echo Press any key to exit...
pause > nul
