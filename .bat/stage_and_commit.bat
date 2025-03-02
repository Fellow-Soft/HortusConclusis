@echo off
echo Staging and committing project reorganization changes...

REM Remove any existing git lock files
if exist ".git\index.lock" del /f ".git\index.lock"

REM Initialize git repository if not already initialized
if not exist ".git" (
    git init
    echo Initialized new git repository
)

REM Stage all changes
git add .

REM Create commit message file
echo Project Reorganization and Code Refactoring > commit_msg.txt
echo. >> commit_msg.txt
echo 1. Directory Structure Improvements: >> commit_msg.txt
echo - Created MD/ directory for documentation >> commit_msg.txt
echo - Created .bat/ directory for batch files >> commit_msg.txt
echo - Organized scripts into functional modules >> commit_msg.txt
echo. >> commit_msg.txt
echo 2. Code Refactoring: >> commit_msg.txt
echo - Standardized naming conventions (removed enhanced/complete suffixes) >> commit_msg.txt
echo - Consolidated helper functions into main classes >> commit_msg.txt
echo - Created common utilities class in scripts/core >> commit_msg.txt
echo. >> commit_msg.txt
echo 3. Documentation Updates: >> commit_msg.txt
echo - Updated reference mapping with new file locations >> commit_msg.txt
echo - Created CHANGELOG.md for version tracking >> commit_msg.txt
echo - Updated project structure documentation >> commit_msg.txt
echo. >> commit_msg.txt
echo 4. Archive Management: >> commit_msg.txt
echo - Moved redundant files to archive with preserved structure >> commit_msg.txt
echo - Created reference mapping for archived files >> commit_msg.txt
echo - Maintained backup of original files >> commit_msg.txt

REM Create commit using the message file
git commit -F commit_msg.txt

REM Clean up
del commit_msg.txt

echo.
echo Changes have been staged and committed.
echo You can now push these changes to the remote repository.
echo.
echo Press any key to exit...
pause > nul
