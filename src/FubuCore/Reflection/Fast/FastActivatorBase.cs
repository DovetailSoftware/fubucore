// Copyright 2007-2010 The Apache Software Foundation.
//  
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
// this file except in compliance with the License. You may obtain a copy of the 
// License at 
// 
//     http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software distributed 
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR 
// CONDITIONS OF ANY KIND, either express or implied. See the License for the 
// specific language governing permissions and limitations under the License.

using System;
using System.Reflection;

namespace FubuCore.Reflection.Fast
{
    public abstract class FastActivatorBase
	{
		const BindingFlags _constructorBindingFlags = BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic;

		protected readonly ConstructorInfo[] Constructors;

		protected FastActivatorBase(Type type)
		{
			ObjectType = type;
			Constructors = type.GetConstructors(_constructorBindingFlags);
		}

		protected Type ObjectType { get; set; }
	}
}