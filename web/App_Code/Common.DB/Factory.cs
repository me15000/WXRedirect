namespace Common.DB
{
    using System.Configuration;

    /// <summary>
    /// DBFactory 的摘要说明
    /// </summary>
    public class Factory
    {
        public Factory()
        {
            //
            // TODO: 在此处添加构造函数逻辑
            //
        }

        public static IDBHelper CreateDBHelper()
        {
            return CreateDBHelper("default");
        }




        public static IDBHelper CreateDBHelper(string connectionKey)
        {
            return new SQLServer.DBHelper(ConfigurationManager.ConnectionStrings[connectionKey].ConnectionString);
        }


  

    }
}