using System;
using System.Collections.Generic;
using UnityEditor.UIElements;

namespace Dragon.Fsm
{   /// <summary>
    /// 有限状态机接口
    /// </summary>
    /// <typeparam name="T">有限状态机持有者类型</typeparam>
    public interface IFsm<T> where T : class
    {
        string Name { get; }

        string FullName { get; }

        T Ower { get; }

        int FsmStateCount { get; }

        bool IsRunning { get; }

        bool IsDestroyed { get; }

        FsmState<T> CurrentState { get; }

        float CurrentStateTime { get; }

        void Start<TState>() where TState : FsmState<T>;

        void Start(Type stateType);

        bool HasState<TState>() where TState : FsmState<T>;

        bool HasState(Type stateType);

        TState GetState<TState>() where TState : FsmState<T>;

        FsmState<T> GetState(Type stateType);

        FsmState<T>[] GetAllStates();

        void GetAllStates(List<FsmState<T>> results);

        bool HasData(string name);

        TData GetData<TData>(string name);
        
        
    }
}