/*
 * Copyright (C) 2012 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.android.builder.resources;

import com.android.builder.TestUtils;
import com.google.common.collect.Maps;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 */
public class ValueResourceParserTest extends BaseTestCase {

    private static List<Resource> sResources = null;

    public void testParsedResourcesByCount() throws Exception {
        List<Resource> resources = getParsedResources();

        assertEquals(18, resources.size());
    }

    public void testParsedResourcesByName() throws Exception {
        List<Resource> resources = getParsedResources();
        Map<String, Resource> resourceMap = Maps.newHashMapWithExpectedSize(resources.size());
        for (Resource item : resources) {
            resourceMap.put(item.getKey(), item);
        }

        String[] resourceNames = new String[] {
                "drawable/color_drawable",
                "drawable/drawable_ref",
                "color/color",
                "string/basic_string",
                "string/xliff_string",
                "string/styled_string",
                "style/style",
                "array/string_array",
                "attr/dimen_attr",
                "attr/string_attr",
                "attr/enum_attr",
                "attr/flag_attr",
                "declare-styleable/declare_styleable",
                "dimen/dimen",
                "id/item_id",
                "integer/integer",
                "layout/layout_ref"
        };

        for (String name : resourceNames) {
            assertNotNull(name, resourceMap.get(name));
        }
    }

    private static List<Resource> getParsedResources() throws IOException {
        if (sResources == null) {
            File root = TestUtils.getRoot("baseResourceSet");
            File values = new File(root, "values");
            File valuesXml = new File(values, "values.xml");

            ValueResourceParser parser = new ValueResourceParser(valuesXml);
            sResources = parser.parseFile();

            // create a fake resource file to allow calling Resource.getKey()
            new ResourceFile(valuesXml, sResources, "");
        }

        return sResources;
    }
}