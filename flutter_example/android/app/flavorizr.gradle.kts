import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.cleany.cleanyStore.dev"
            resValue(type = "string", name = "app_name", value = "cleany_store Dev")
        }
        create("uat") {
            dimension = "flavor-type"
            applicationId = "com.cleany.cleanyStore.uat"
            resValue(type = "string", name = "app_name", value = "cleany_store UAT")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.cleany.cleanyStore"
            resValue(type = "string", name = "app_name", value = "cleany_store")
        }
    }

    buildFeatures.resValues = true
}