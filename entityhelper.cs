using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;

using System.Data.Objects;
using System.Linq.Expressions;
using System.Configuration;
using System.Transactions;
using System.Data.Entity;

namespace DBHelper
{
    public class EntityHelper
    {
        private readonly string conn = "name=B2bDBEntities";

        private ObjectContext db;

        /// <summary>
        ///  调用时注入同一个上下文对象
        /// </summary>
        /// <param name="oc"></param>
        public EntityHelper(ObjectContext oc)
        {
            if (db == null)
            {
                db = oc;
                db.Connection.ConnectionString = conn;
            }
        }
        /// <summary>
        ///  执行查询全部数据的操作
        /// </summary>
        /// <typeparam name="T">欲查询的实体</typeparam>
        /// <returns>返回List T 类型数据</returns>
        public List<T> GetAllList<T>(bool deferred = true, string path = null) where T : class
        {
            ObjectContextOptions oco = db.ContextOptions;
            oco.LazyLoadingEnabled = deferred;   // 在禁用掉lazy  后使用include方法加载额外数据
            if (!deferred)
            {
                return db.CreateObjectSet<T>().Include(path).ToList();
            }
            else
            {
                return db.CreateObjectSet<T>().ToList();
            }
        }

        /// <summary>
        ///  执行查询部分数据的操作
        /// </summary>
        /// <typeparam name="T">欲查询的实体</typeparam>
        /// <param name="expression"></param>
        /// <returns></returns>
        public List<T> GetList<T>(Expression<Func<T, bool>> expression, bool deferred = true, string path = null) where T : class
        {
            ObjectContextOptions oco = db.ContextOptions;
            oco.LazyLoadingEnabled = deferred;
            if (!deferred)
            {
                return db.CreateObjectSet<T>().Where(expression).Include(path).ToList();
            }
            else
            {
                return db.CreateObjectSet<T>().Where(expression).ToList();
            }
        }

        /// <summary>
        ///  执行查询指定实体的操作
        /// </summary>
        /// <typeparam name="T">欲查询的实体</typeparam>
        /// <returns></returns>
        public T GetEntity<T>(Func<T, bool> expression, bool deferred = true, string path = null) where T : class
        { 
            ObjectContextOptions oco = db.ContextOptions;
            oco.LazyLoadingEnabled = deferred;
            if (!deferred)
            {
                return db.CreateObjectSet<T>().Where(expression).Include(path).FirstOrDefault();
            }
            else
            {
                return db.CreateObjectSet<T>().Where(expression).FirstOrDefault();
            }
        }

        /// <summary>
        ///  添加一个新实体
        /// </summary>
        /// <typeparam name="T">欲添加的实体</typeparam>
        /// <param name="entity"></param>
        /// <returns></returns>
        public bool InsertObject<T>(T entity) where T : class
        {
            using (TransactionScope scope = new TransactionScope())
            {
                try
                {
                    db.AddObject(typeof(T).Name, entity);
                    db.SaveChanges();
                    scope.Complete();
                    return true;
                }
                catch (Exception ex)
                {
                    throw new Exception(ex.InnerException.Message);
                }
            }
        }

        /// <summary>
        ///  删除数据库实体
        /// </summary>
        /// <typeparam name="T">欲删除的实体</typeparam>
        /// <param name="expression">lambda表达式</param>
        /// <returns>操作结果</returns>
        public bool DeleteObject<T>(Expression<Func<T, bool>> expression) where T : class
        {
            using (TransactionScope scope = new TransactionScope())
            {
                try
                {
                    db.DeleteObject(db.CreateObjectSet<T>().Where(expression).FirstOrDefault());
                    db.SaveChanges();
                    scope.Complete();
                    return true;
                }
                catch (Exception ex)
                { 
                    throw new Exception(ex.InnerException.Message);
                }
            }
        }

        /// <summary>
        ///  修改数据库实体
        /// </summary>
        /// <typeparam name="T">欲修改的实体(需要查询修改)</typeparam>
        /// <param name="entity"></param>
        /// <returns></returns>
        public bool UpdateObject<T>(T entity) where T : class
        {
            using (TransactionScope scope = new TransactionScope())
            {
                try
                {
                    //db.ApplyOriginalValues<T>(typeof(T).Name, entity);
                    db.SaveChanges();
                    scope.Complete();
                    return true;
                }
                catch (Exception ex)
                {
                    throw new Exception(ex.InnerException.Message);
                }
            }
        }

        /// <summary>
        ///  修改数据库实体
        /// </summary>
        /// <typeparam name="T">欲修改的实体(不需要查询修改,一定要是新实体)</typeparam>
        /// <param name="entity"></param>
        /// <returns></returns>
        public bool UpdateObject<T>(T entity, string[] args) where T : class
        {
            using (TransactionScope scope = new TransactionScope())
            {
                try
                {
                    db.AttachTo(typeof(T).Name, entity);
                    var newobj = db.ObjectStateManager.GetObjectStateEntry(entity);
                    newobj.SetModified();
                    for (int i = 0; i < args.Length; i++)
                    {
                        newobj.SetModifiedProperty(args[i]);
                    }
                    db.SaveChanges();
                    scope.Complete();
                    return true;
                }
                catch (Exception ex)
                {
                    throw new Exception(ex.InnerException.Message);
                }
            }
        }

        /// <summary>
        ///  返回分页数据
        /// </summary>
        /// <typeparam name="T">欲产生分页的数据实体</typeparam>
        /// <param name="pageSize"></param>
        /// <param name="pageIndex"></param>
        /// <returns></returns>
        public List<T> GetPager<T>(Expression<Func<T, object>> expression, int pageSize, int pageIndex) where T : class
        {
            return db.CreateObjectSet<T>().OrderBy(expression).Skip((pageIndex - 1) * pageSize).Take(pageSize).ToList();
        }

        /// <summary>
        ///  调用sql语句执行查询操作
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="sql"></param>
        /// <param name="pars"></param>
        /// <returns></returns>
        public List<T> GetListQuerySql<T>(string sql, params object[] pars)
        {
            using (DbContext db = new DbContext(conn))
            {
                Database dbb = db.Database;
                return dbb.SqlQuery<T>(sql, pars).ToList();
            }
        }

        /// <summary>
        ///  调用sql语句执行DML操作
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="sql"></param>
        /// <param name="pars"></param>
        /// <returns></returns>
        public bool DMLOperation<T>(string sql, params object[] pars)
        {
            using (TransactionScope scope = new TransactionScope())
            {
                using (DbContext db = new DbContext(conn))
                {
                    Database dbb = db.Database;
                    if (dbb.ExecuteSqlCommand(sql, pars) > 0)
                    {
                        scope.Complete();
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
            }
        }

        /// <summary>
        ///  调用查询存储过程
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="procName"></param>
        /// <param name="mo"></param>
        /// <param name="pars"></param>
        /// <returns></returns>
        public List<T> QueryProceDure<T>(string procName, params ObjectParameter[] pars)
        {
            return db.ExecuteFunction<T>(procName, pars).ToList();
        }

        /// <summary>
        ///  调用DML存储过程
        /// </summary>
        /// <param name="procName"></param>
        /// <param name="pars"></param>
        /// <returns></returns>
        public bool DMLProcedure(string procName, params ObjectParameter[] pars)
        {
            using (TransactionScope scope = new TransactionScope())
            {
                try
                {
                    if (db.ExecuteFunction(procName, pars) > 0)
                    {
                        scope.Complete();
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
                catch (Exception ex)
                {
                    throw new Exception(ex.InnerException.Message);
                }
            }
        }
    }
}
