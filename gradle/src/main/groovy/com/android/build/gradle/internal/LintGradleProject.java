package com.android.build.gradle.internal;

import com.android.annotations.NonNull;
import com.android.build.gradle.BasePlugin;
import com.android.build.gradle.LibraryPlugin;
import com.android.build.gradle.internal.model.ModelBuilder;
import com.android.builder.model.AndroidLibrary;
import com.android.builder.model.AndroidProject;
import com.android.builder.model.Variant;
import com.android.tools.lint.client.api.LintClient;
import com.android.tools.lint.detector.api.Project;

import java.io.File;
import java.util.Collections;

public class LintGradleProject extends Project {
    private AndroidProject mProject;

    LintGradleProject(
            @NonNull LintClient client,
            @NonNull File dir,
            @NonNull File referenceDir) {
        super(client, dir, referenceDir);

        mGradleProject = true;
        mMergeManifests = true;
        mDirectLibraries = Collections.emptyList();
    }

    @Override
    protected void initialize() {
        // Deliberately not calling super; that code is for ADT compatibility
    }

    @Override
    public boolean isGradleProject() {
        return true;
    }

    @Override
    public boolean isLibrary() {
        LintGradleClient client = (LintGradleClient) mClient;
        BasePlugin plugin = client.getPlugin();
        return plugin instanceof LibraryPlugin;
    }

    @Override
    public AndroidProject getGradleProjectModel() {
        if (mProject == null) {
            LintGradleClient client = (LintGradleClient) mClient;
            BasePlugin plugin = client.getPlugin();
            String modelName = AndroidProject.class.getName();
            ModelBuilder builder = new ModelBuilder();
            mProject = (AndroidProject) builder.buildAll(modelName, plugin.getProject());
        }

        return mProject;
    }

    @Override
    public AndroidLibrary getGradleLibraryModel() {
        return null;
    }

    @Override
    public Variant getCurrentVariant() {
        return null;
    }
}
