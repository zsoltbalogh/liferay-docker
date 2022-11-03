package test

import org.apache.commons.io.FileUtils

import java.util.concurrent.TimeUnit

/**
 * @author Josef Sustacek
 */
interface Orca {
    File sharedVolumePath()
    File buildsPath()
    default File specResultsBasePath() {
        return new File(System.getProperty('ORCA_TEST__SPEC_RESULTS_BASE_PATH'))
    }
    List<String> orcaRunCommandParts()

    default Process startOrca(Map envVars, List<String> orcaArgs) {
        def orca = orcaRunCommandParts() + orcaArgs

        return startSubProcess(envVars, orca.toArray(new String[0]))
    }

    default File featureTestResultsDir(String specName, String featureName, int iterationIndex) {
        def specResultsDir = new File(specResultsBasePath(), specName)

        return new File(specResultsDir, "feature_${featureName.hashCode()}_${iterationIndex}")
    }

    default void setupSpec() {
    }

    default void cleanupSpec() {
    }

    // before one Orca run (~ 1 Spock spec)
    default void setup(String specName, String featureName, int iterationIndex) {
        // expected to be present for the 'docker -v ...' mounts, so need to be created
        // before the RUN command is executed
        sharedVolumePath().mkdirs()
        buildsPath().mkdirs()

        // where results will be written
        def featureTestResultsDir = featureTestResultsDir(specName, featureName, iterationIndex)

        featureTestResultsDir.deleteDir()
        featureTestResultsDir.mkdirs()
    }

    // after one Orca run (~ 1 Spock spec)
    default void cleanup(String specName, String featureName, int iterationIndex, OrcaRun orcaRun) {
        def buildsPath = buildsPath()
        def sharedVolumePath = sharedVolumePath()

        // archive the results
        def featureTestResultsDir = featureTestResultsDir(specName, featureName, iterationIndex)
        FileUtils.copyDirectory(buildsPath, new File(featureTestResultsDir, buildsPath.name))
        FileUtils.copyDirectory(sharedVolumePath, new File(featureTestResultsDir, sharedVolumePath.name))

        // write stdout to file
        def stdoutFile = new File(featureTestResultsDir, "orca_stdout.txt")
        stdoutFile.text = """\
# Feature: ${featureName} (#${iterationIndex})
${orcaRun.orcaEnvVars ? (orcaRun.orcaEnvVars.collect { k, v -> "#  * ${k}=${v}"}.join('\n')) : '# no ENV vars'}
\$ orca ${orcaRun.orcaArgs.join(' ')}

${orcaRun.stdout}"""

        print "Feature run results (Orca builds dir, shared volume, stdout as a file...) archived in '${featureTestResultsDir.absolutePath}'"

        // clean the "build" dirs of ORCA
        FileUtils.cleanDirectory(buildsPath)
        FileUtils.cleanDirectory(sharedVolumePath)
    }

    // helper methods
    default ProcessBuilder buildSubProcess(Map envVars, String... command) {
        def pb = new ProcessBuilder(command)
        pb.redirectErrorStream(true)

        pb = applyEnvVars(pb, envVars)

        return pb
    }

    default Process startSubProcess(Map envVars, String... command) {
        def processBuilder = buildSubProcess(envVars, command)

        println "Starting sub-process: \n  " + processBuilder.command().join(' ')

        // merge stdout + stderr
        processBuilder.redirectErrorStream(true)

        // this would cause streaming to stdout
        //        processBuilder.inheritIO()

        return processBuilder.start()
    }

    ProcessBuilder applyEnvVars(ProcessBuilder subProcessBuilder, Map envVarsToSet)

}

class NativeOrca implements Orca {

    File sharedVolumePath() {
        // as hard-coded in ORCA sources
        return new File('/opt/liferay/shared-volume')
    }

    @Override
    File buildsPath() {
        // as hard-coded in ORCA sources
        return new File('/opt/liferay/orca/builds')
    }

    @Override
    List<String> orcaRunCommandParts() {
        // has to be in $PATH
        return 'orca'
    }

    ProcessBuilder applyEnvVars(ProcessBuilder subProcessBuilder, Map envVarsToSet) {
        // set ENV on the subprocess itself
        subProcessBuilder.environment().putAll(envVarsToSet ?: [:])

        return subProcessBuilder
    }

}

class DockerOrca implements Orca {

    File sharedVolumePath() {
        return new File(System.getProperty('ORCA_TEST_DOCKER__SHARED_VOLUME_PATH'))
    }

    File buildsPath() {
        return new File(System.getProperty('ORCA_TEST_DOCKER__BUILDS_PATH'))
    }

    ProcessBuilder applyEnvVars(ProcessBuilder subProcessBuilder, Map envVarsToSet) {
        if (!envVarsToSet) {
            return subProcessBuilder
        }

        def envVarsAsDockerArgs = envVarsToSet.collect { k, v ->
            [ '-e', "${k}=${v}" as String ]
        }.flatten()

        // the process will be a Docker command, so add multiple '-e', "key=value"' to the command parts
        def originalCommand = subProcessBuilder.command()

//        println "Original command: ${originalCommand}"

        def fistBindArgIndex = originalCommand.indexOf('-v')

        def newCommand =
                originalCommand.plus(fistBindArgIndex, envVarsAsDockerArgs)

//        println "New command: ${newCommand}"

        subProcessBuilder.command(newCommand)

        return subProcessBuilder
    }

    // The 'run' command for Orca as passed from Gradle
    List<String> orcaRunCommandParts() {
        def separator = System.getProperty('ORCA_TEST_DOCKER__COMMAND_PARTS_SEPARATOR')
        def parts = System.getProperty('ORCA_TEST_DOCKER__RUN_COMMAND_PARTS')

        return parts.split(separator)?.toList()
    }

    // The 'cleanup' command for Orca, as passed from Gradle
    List<String> orcaCleanBeforeRunCommandParts() {
        def separator = System.getProperty('ORCA_TEST_DOCKER__COMMAND_PARTS_SEPARATOR')
        def parts = System.getProperty('ORCA_TEST_DOCKER__CLEAN_COMMAND_PARTS')

        return parts.split(separator)?.toList()
    }

    void setup() {
        def orcaCleanBeforeRun =
                startSubProcess([:], orcaCleanBeforeRunCommandParts().toArray(new String[0]))

        orcaCleanBeforeRun.waitFor(15, TimeUnit.SECONDS)

//        println "ORCA CLEAN: " + orcaCleanBeforeRun.inputStream.text
    }

}
