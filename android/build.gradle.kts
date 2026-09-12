allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    if (project.path != ":app") {
        rootProject.findProject(":app")?.let { appProject ->
            project.evaluationDependsOn(appProject.path)
        }
    }
}

tasks.register<Delete>("clean") {
    description = "Limpia el directorio de compilación del proyecto."
    delete(rootProject.layout.buildDirectory)
}