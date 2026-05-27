#!/usr/bin/env node

const fs = require('fs')
const path = require('path')

function replaceTextInFile(fileName, textInFile, replacementText) {
    const contents = fs.readFileSync(fileName, 'utf8')
    const result = contents.replace(textInFile, replacementText)
    fs.writeFileSync(fileName, result, 'utf8')
}

function getSwiftPackageConfig() {
    const packageJson = require('./package.json')
    const sdkValue = packageJson.sdkDependencies["SalesforceMobileSDK-iOS"]
        || packageJson.sdkDependencies["SalesforceMobileSDK-iOS-SPM"]

    if (!sdkValue) {
        console.error('No SalesforceMobileSDK-iOS or SalesforceMobileSDK-iOS-SPM in sdkDependencies')
        process.exit(1)
    }

    // Local path mode: value starts with "/" or "./" or "../"
    if (sdkValue.startsWith('/') || sdkValue.startsWith('./') || sdkValue.startsWith('../')) {
        return { mode: 'local', relativePath: sdkValue }
    }

    // Remote mode: URL#branch or URL#version
    const parts = sdkValue.split('#')
    const repoUrl = parts[0].replace(/\.git$/, '')
    const branchOrTag = parts.length > 1 ? parts[1] : 'dev'
    return { mode: 'remote', repoUrl: repoUrl, branchOrTag: branchOrTag }
}

function fixProjectFileRemote(repoUrl, kind, key, value) {
    const projectDirName = fs.readdirSync('.').filter(f => f.endsWith('xcodeproj'))[0]
    const projectFilePath = `./${projectDirName}/project.pbxproj`

    replaceTextInFile(projectFilePath,
        /repositoryURL = ".*SalesforceMobileSDK-iOS.*";\s*requirement = {[^}]*};/m,
        `repositoryURL = "${repoUrl}";\n\t\t\trequirement = {\n\t\t\t\tkind = ${kind};\n\t\t\t\t${key} = ${value};\n\t\t\t};`)
}

function fixProjectFileLocal(relativePath) {
    const projectDirName = fs.readdirSync('.').filter(f => f.endsWith('xcodeproj'))[0]
    const projectFilePath = `./${projectDirName}/project.pbxproj`
    let contents = fs.readFileSync(projectFilePath, 'utf8')

    // Replace XCRemoteSwiftPackageReference section with XCLocalSwiftPackageReference
    contents = contents.replace(
        /\/\* Begin XCRemoteSwiftPackageReference section \*\/[\s\S]*?\/\* End XCRemoteSwiftPackageReference section \*\//m,
        `/* Begin XCLocalSwiftPackageReference section */\n` +
        `\t\t4FFBC6582A5DC21B004CF964 /* XCLocalSwiftPackageReference "SalesforceMobileSDK-iOS" */ = {\n` +
        `\t\t\tisa = XCLocalSwiftPackageReference;\n` +
        `\t\t\trelativePath = ${relativePath};\n` +
        `\t\t};\n` +
        `/* End XCLocalSwiftPackageReference section */`)

    // Update package references comment
    contents = contents.replace(
        /XCRemoteSwiftPackageReference "SalesforceMobileSDK-iOS"/g,
        `XCLocalSwiftPackageReference "SalesforceMobileSDK-iOS"`)

    fs.writeFileSync(projectFilePath, contents, 'utf8')
}

const config = getSwiftPackageConfig()

if (config.mode === 'local') {
    console.log(`Using local Swift Package at ${config.relativePath}`)
    fixProjectFileLocal(config.relativePath)
} else {
    console.log(`Using remote Swift Package ${config.repoUrl} at ${config.branchOrTag}`)
    if (isNaN(parseInt(config.branchOrTag))) {
        fixProjectFileRemote(config.repoUrl, 'branch', 'branch', config.branchOrTag)
    } else {
        fixProjectFileRemote(config.repoUrl, 'exactVersion', 'version', config.branchOrTag)
    }
}
