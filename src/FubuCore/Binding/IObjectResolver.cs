using System;

namespace FubuCore.Binding
{
    public interface IObjectResolver
    {
        BindResult BindModel(Type type, IRequestData data);

        [MarkedForTermination("Eliminate!")]
        BindResult BindModel(Type type, IBindingContext context);

        /// <summary>
        /// Use this method when the type may not have a matching IModelBinder
        /// </summary>
        /// <param name="type"></param>
        /// <param name="context"></param>
        /// <param name="onResult"></param>
        [MarkedForTermination]
        void TryBindModel(Type type, IBindingContext context, Action<BindResult> continuation);

        [MarkedForTermination]
        BindResult BindModel<T>(T model, IBindingContext context);
        
        
        void TryBindModel(Type type, IRequestData data, Action<BindResult> continuation);
    }
}