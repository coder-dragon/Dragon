#if USE_UNI_LUA
using LuaAPI = UniLua.Lua;
using RealStatePtr = UniLua.ILuaState;
using LuaCSFunction = UniLua.CSharpFunctionDelegate;
#else
using LuaAPI = XLua.LuaDLL.Lua;
using RealStatePtr = System.IntPtr;
using LuaCSFunction = XLua.LuaDLL.lua_CSFunction;
#endif

using System;
using System.Collections.Generic;
using System.Reflection;


namespace XLua.CSObjectWrap
{
    public class XLua_Gen_Initer_Register__
	{
        
        
        static void wrapInit0(LuaEnv luaenv, ObjectTranslator translator)
        {
        
            translator.DelayWrapLoader(typeof(Dragon.LuaExtensions.LuaInjection), DragonLuaExtensionsLuaInjectionWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(Dragon.Pooling.GameObjectPool), DragonPoolingGameObjectPoolWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(Dragon.LuaExtensions.UnityEngineObjectExtention), DragonLuaExtensionsUnityEngineObjectExtentionWrap.__Register);
        
        
            translator.DelayWrapLoader(typeof(Dragon.GameObjectExtenstion), DragonGameObjectExtenstionWrap.__Register);
        
        
        
        }
        
        static void Init(LuaEnv luaenv, ObjectTranslator translator)
        {
            
            wrapInit0(luaenv, translator);
            
            
        }
        
	    static XLua_Gen_Initer_Register__()
        {
		    XLua.LuaEnv.AddIniter(Init);
		}
		
		
	}
	
}
namespace XLua
{
	public partial class ObjectTranslator
	{
		static XLua.CSObjectWrap.XLua_Gen_Initer_Register__ s_gen_reg_dumb_obj = new XLua.CSObjectWrap.XLua_Gen_Initer_Register__();
		static XLua.CSObjectWrap.XLua_Gen_Initer_Register__ gen_reg_dumb_obj {get{return s_gen_reg_dumb_obj;}}
	}
	
	internal partial class InternalGlobals
    {
	    
		delegate bool __GEN_DELEGATE0( UnityEngine.Object o);
		
		delegate UnityEngine.Component __GEN_DELEGATE1( UnityEngine.GameObject go,  System.Type type);
		
		delegate UnityEngine.GameObject __GEN_DELEGATE2( UnityEngine.GameObject go);
		
		delegate void __GEN_DELEGATE3( UnityEngine.GameObject go);
		
		delegate int __GEN_DELEGATE4( UnityEngine.GameObject go,  int initialSize);
		
		delegate void __GEN_DELEGATE5( UnityEngine.GameObject go);
		
	    static InternalGlobals()
		{
		    extensionMethodMap = new Dictionary<Type, IEnumerable<MethodInfo>>()
			{
			    
				{typeof(UnityEngine.Object), new List<MethodInfo>(){
				
				  new __GEN_DELEGATE0(Dragon.LuaExtensions.UnityEngineObjectExtention.IsNull)
#if UNITY_WSA && !UNITY_EDITOR
                                      .GetMethodInfo(),
#else
                                      .Method,
#endif
				
				}},
				
				{typeof(UnityEngine.GameObject), new List<MethodInfo>(){
				
				  new __GEN_DELEGATE1(Dragon.GameObjectExtenstion.GetOrAddComponent)
#if UNITY_WSA && !UNITY_EDITOR
                                      .GetMethodInfo(),
#else
                                      .Method,
#endif
				
				  new __GEN_DELEGATE2(Dragon.GameObjectExtenstion.GetFromPool)
#if UNITY_WSA && !UNITY_EDITOR
                                      .GetMethodInfo(),
#else
                                      .Method,
#endif
				
				  new __GEN_DELEGATE3(Dragon.GameObjectExtenstion.ReturnToPool)
#if UNITY_WSA && !UNITY_EDITOR
                                      .GetMethodInfo(),
#else
                                      .Method,
#endif
				
				  new __GEN_DELEGATE4(Dragon.GameObjectExtenstion.CreatePool)
#if UNITY_WSA && !UNITY_EDITOR
                                      .GetMethodInfo(),
#else
                                      .Method,
#endif
				
				  new __GEN_DELEGATE5(Dragon.GameObjectExtenstion.CreatePool)
#if UNITY_WSA && !UNITY_EDITOR
                                      .GetMethodInfo(),
#else
                                      .Method,
#endif
				
				}},
				
			};
			
			genTryArrayGetPtr = StaticLuaCallbacks.__tryArrayGet;
            genTryArraySetPtr = StaticLuaCallbacks.__tryArraySet;
		}
	}
}
