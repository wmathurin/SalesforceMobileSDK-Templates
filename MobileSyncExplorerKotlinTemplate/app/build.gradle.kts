plugins {
    android
    `kotlin-android`
}

dependencies {
    implementation("androidx.activity:activity-compose:1.10.0")
    implementation("androidx.compose.material:material:1.7.7")
    implementation("androidx.compose.material:material-android:1.7.7")
    implementation("androidx.compose.material:material-icons-core-android:1.7.7")
    implementation("androidx.compose.runtime:runtime-android:1.7.7")
    implementation("androidx.compose.ui:ui:1.7.7")
    implementation("androidx.compose.ui:ui-tooling-preview:1.7.7")
    implementation("androidx.core:core-ktx:1.15.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.7")
    implementation("androidx.window:window:1.3.0")

    implementation("com.salesforce.mobilesdk:MobileSync:13.0.1")

    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.2.1")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.6.1")
    androidTestImplementation("androidx.compose.ui:ui-test-junit4:1.7.7")
    debugImplementation("androidx.compose.ui:ui-tooling:1.7.7")
    debugImplementation("androidx.compose.ui:ui-test-manifest:1.7.7")
    implementation("androidx.core:core-ktx:1.15.0")
}

android {
    namespace = "com.salesforce.mobilesyncexplorerkotlintemplate"

    compileSdk = 35

    defaultConfig {
        applicationId = "com.salesforce.mobilesyncexplorerkotlintemplate"
        targetSdk = 35
        minSdk = 28
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        vectorDrawables {
            useSupportLibrary = true
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        compose = true
        aidl = true
        renderScript = true
        buildConfig = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.5"
    }

    packaging {
        resources {
            excludes += setOf("/META-INF/{AL2.0,LGPL2.1}", "META-INF/LICENSE", "META-INF/LICENSE.txt", "META-INF/DEPENDENCIES", "META-INF/NOTICE")
        }
    }

    sourceSets {
        getByName("main") {
            manifest.srcFile("AndroidManifest.xml")
            java.srcDirs(arrayOf("src/main/java"))
            resources.srcDirs(arrayOf("src/main/java"))
            aidl.srcDirs(arrayOf("src/main"))
            renderscript.srcDirs(arrayOf("src/main"))
            res.srcDirs(arrayOf("src/main/res"))
            assets.srcDirs(arrayOf("src/main/assets"))
        }
    }
}

repositories {
    google()
    mavenCentral()
}
