package test

/**
 * @author Josef Sustacek
 */
class OrcaRun {
    final Map<String, String> orcaEnvVars
    final List<String> orcaArgs

    // The process executing Orca
    final Process process

    // stdout recorded from process once it finished (or timeout elapses)
    final String stdout

    OrcaRun(Map<String, String> orcaEnvVars, List<String> orcaArgs, Process process, String stdout) {
        this.orcaArgs = orcaArgs
        this.orcaEnvVars = orcaEnvVars
        this.process = process
        this.stdout = stdout
    }

}
