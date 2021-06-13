using Dragon.Pooling;

namespace Dragon
{
    /// <summary>
    /// ��Դ�������ӿ�
    /// </summary>
    public interface IAssetLoader : IPoolable
    {
        /// <summary>
        /// ��ȡ������־
        /// </summary>
        string Error { get; }

        /// <summary>
        /// ��ȡһ��ֵ����ʾ���������Ƿ��Ѿ�����
        /// </summary>
        bool IsDone { get; }

        /// <summary>
        /// ��ȡ���ؽ���
        /// </summary>
        float Progress { get; }

        /// <summary>
        /// ��ȡ���صĽ��
        /// </summary>
        object Result { get; }

        /// <summary>
        /// ��ȡ��Ҫ���ص���Դ�Ķ�λ��ʶ��
        /// </summary>
        string Uri { get; }

        /// <summary>
        /// ����������
        /// </summary>
        void Start();
    }

}