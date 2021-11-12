// Copyright (c) 2021 SAP SE or an SAP affiliate company. All rights reserved. This file is licensed under the Apache Software License, v. 2 except as noted otherwise in the LICENSE file
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package features

import (
	utilruntime "k8s.io/apimachinery/pkg/util/runtime"
	"k8s.io/component-base/featuregate"
)

const (
	// Every feature gate should add method here following this template:
	//
	// // MyFeature enable Foo.
	// // owner: @username
	// // alpha: v0.5.X
	// MyFeature featuregate.Feature = "MyFeature"

	// BackupCompaction enables an event count based compaction for etcd backups.
	// owner @abdasgupta, @timuthy
	// alpha: v0.7.0
	BackupCompaction featuregate.Feature = "BackupCompaction"
)

var (
	// FeatureGate is a shared global FeatureGate for Etcd-Druid flags.
	FeatureGate  = featuregate.NewFeatureGate()
	featureGates = map[featuregate.Feature]featuregate.FeatureSpec{
		BackupCompaction: {Default: false, PreRelease: featuregate.Alpha},
	}
)

// RegisterFeatureGates registers the feature gates of Etcd-Druid.
func RegisterFeatureGates() {
	utilruntime.Must(FeatureGate.Add(featureGates))
}
