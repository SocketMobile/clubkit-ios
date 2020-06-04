#!/usr/bin/python
import sys
import re
import os
import glob
import time
import subprocess

def updateVersionFiles(files, currentVersion, newVersion):
    year = time.strftime('%Y')
    regexVersion = currentVersion
    regexYear = '\d+ Socket Mobile, Inc.'
    for file in files:
        print 'updating the version in the ' + file + ' to ' + newVersion
        with open(file, 'r') as src:
            trg = open(file + '-new', 'w')
            lines = src.readlines()
            for line in lines:
                line = re.sub(regexVersion, newVersion, line)
                line = re.sub(regexYear, year + ' Socket Mobile, Inc.', line)
                trg.write(line)
            trg.close()
        os.remove(file)
        os.rename(file + '-new', file)
        
def updatePlistFileVersion(newVersion):

    plistname = '../Example/Pods/Target Support Files/ClubKit/ClubKit-Info.plist'

    if not os.path.exists(plistname):
        print("{0} does not exist".format(plistname))
        return False

    plistbuddy = '/usr/libexec/Plistbuddy'
    if not os.path.exists(plistbuddy):
        print("{0} does not exist".format(plistbuddy))
        return False

    cmdline = [plistbuddy,
        "-c", "Set CFBundleShortVersionString {0}".format(newVersion),
        "-c", "Set CFBundleVersion {0}".format(newVersion),
        plistname]
    if subprocess.call(cmdline) != 0:
        print("Failed to update {0}".format(plistname))
        return False

    print("Updated {0} with v{1}".format(plistname, newVersion))
    return True
        

def updateFiles(targetDirectory, currentVersion, newVersion):
    files = glob.glob(targetDirectory + '/*.txt')
    updateVersionFiles(files, currentVersion, newVersion)
    files = glob.glob(targetDirectory + '/*.podspec')
    updateVersionFiles(files, currentVersion, newVersion)
    updatePlistFileVersion(newVersion)

def getCurrentDir():
    nbParam = len(sys.argv)
    cwd = sys.argv[0]
    path = ''
    if not cwd.startswith('/'):
        path = os.getcwd()
    cwd = cwd.split('/')
    cwd = cwd[:len(cwd)-1]
    for p in cwd:
        if len(p)>0:
            path += '/'
            path += p
    return path

# return the actual version that is the tag
# with the number of commit
# but limit the version to 3 number 10.2.123
def getFullVersion(directory):
    currentDir = os.getcwd()
    os.chdir(directory)
    
    # Returns a value like: 0.1.0-2-gebe2fb1
    # 0 represents the version.major
    # 1 represents the version.middle
    # 0 represents the version.minor
    # 2 represents the version.build
    # gebe2fb1 represents the hash
    describedVersion = subprocess.check_output(['git','describe', '--long'])
    
    # Splits by "\n" (new line) if there are multiple lines.
    # Not likely to happen since the version would not contain this
    oneLinedDescribedVersion = describedVersion.splitlines()[0]
    
    # Splits version by hyphens to single out the build number
    # and the hash. (Array)
    hyphenSeparatedOneLinedDescribedVersion = oneLinedDescribedVersion.split('-')
    
    # Split the current version numbers by .
    # Produces: [0, 1, 0] (Array)
    currentVersionNumbers = hyphenSeparatedOneLinedDescribedVersion[0].split('.')
    
    # Produces the version build number: 2
    versionBuildNumber = hyphenSeparatedOneLinedDescribedVersion[1]
        
    # Reconstructs a string of the current version (excluding the version build number
    # Produces: '0.1.0' (String)
    currentVersion = currentVersionNumbers[0] + '.' + currentVersionNumbers[1] + '.' + currentVersionNumbers[2]
    
    
    finalVersion = currentVersionNumbers[0] + '.' + currentVersionNumbers[1] + '.' + str(int(versionBuildNumber) + 1)

    os.chdir(currentDir)
        
    print 'described version: ' + describedVersion
    print 'current version before this commit: ' + currentVersion
    print 'full version after this commit: ' + finalVersion +' '+directory
    return currentVersion, finalVersion

def commitModifications(version):
    comment = 'update to version ' + version
    print 'git commit -am ' + comment
    output = subprocess.check_output(['git','commit', '-am', comment])

def tagSourceControl(version):
    print 'git tag -a ' + version
    output = subprocess.check_output(['git','tag', '-a', version, '-m', 'update version'])

def main():
    target = getCurrentDir()
    currentVersion, newVersion = getFullVersion(target)
    updateFiles(target + '/..', currentVersion, newVersion)
    commitModifications(newVersion)
    tagSourceControl(newVersion)

if __name__ == '__main__':
    result = main()
    sys.exit(result)
