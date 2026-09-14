import java.lang.reflect.Proxy

/**
 * Flutter 3.44 scanne le texte des `build.gradle` des plugins et affiche un WARNING
 * dès qu'il voit `apply plugin: 'kotlin-android'`. Les plugins Firebase le gardent
 * derrière `if (!builtInKotlin)`, donc le warning est un faux positif.
 * On filtre uniquement ce message — le build n'est pas modifié.
 */
@Suppress("UNCHECKED_CAST")
fun suppressFlutterKgpWarning() {
    val phrases = listOf(
        "Kotlin Gradle Plugin (KGP)",
        "plugins that apply Kotlin Gradle Plugin",
        "Future versions of Flutter will fail to build if your app uses plugins that apply KGP",
        "Please check the changelogs of these plugins",
        "If no such version exists, report the issue to the plugin",
        "If you are a plugin author, please migrate your plugin to Built-in Kotlin",
        "migrate-to-built-in-kotlin",
    )
    try {
        val factory = org.slf4j.LoggerFactory.getILoggerFactory()
        val contextClass =
            Class.forName("org.gradle.internal.logging.slf4j.OutputEventListenerBackedLoggerContext")
        if (!contextClass.isInstance(factory)) return
        val listenerClass = Class.forName("org.gradle.internal.logging.events.OutputEventListener")
        val original = contextClass.getMethod("getOutputEventListener").invoke(factory)
        val proxy =
            Proxy.newProxyInstance(listenerClass.classLoader, arrayOf(listenerClass)) { _, method, args ->
                var skip = false
                if (method.name == "onOutput" && !args.isNullOrEmpty()) {
                    val event = args[0]
                    val text = buildString {
                        append(event.toString())
                        runCatching {
                            val getMessage =
                                event.javaClass.methods.firstOrNull {
                                    it.name == "getMessage" && it.parameterCount == 0
                                }
                            append(' ')
                            append(getMessage?.invoke(event) ?: "")
                        }
                        runCatching {
                            val getSpans =
                                event.javaClass.methods.firstOrNull {
                                    it.name == "getSpans" && it.parameterCount == 0
                                }
                            val spans = getSpans?.invoke(event) as? List<*>
                            spans?.forEach { append(' ').append(it.toString()) }
                        }
                    }
                    skip = phrases.any { text.contains(it) }
                }
                when {
                    skip -> null
                    args == null -> method.invoke(original)
                    else -> method.invoke(original, *args)
                }
            }
        contextClass.getMethod("setOutputEventListener", listenerClass).invoke(factory, proxy)
    } catch (_: Exception) {
        // Si les internals Gradle changent, le warning peut réapparaître.
    }
}

suppressFlutterKgpWarning()

pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.0.1" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.4.4") apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
}

include(":app")
