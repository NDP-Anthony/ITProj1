package Services;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class DBProvider {
    /**
     * Connection for MSSQL-SERVER
     */
    // private static String DB_URL = "jdbc:sqlserver://localhost:1433;databaseName=itproject1";
    // private static String USER_NAME = "sa";
    // private static String PASSWORD = "Ndpfree@192";
    // private static String DRIVER_CLASS = "com.microsoft.sqlserver.jdbc.SQLServerDriver";

    /**
     * Connection for MYSQL
     */
    // private static String DB_URL = "jdbc:mysql://123.21.133.33:3306/itproject1";
    // private static String USER_NAME = "root";
    // private static String PASSWORD = "123456";
    // private static String DRIVER_CLASS = "com.mysql.jdbc.Driver";

    private static String DB_URL = "jdbc:mysql://sql12.freemysqlhosting.net:3306/sql12383988";
    private static String USER_NAME = "sql12383988";
    private static String PASSWORD = "68eDMvQaje";
    private static String DRIVER_CLASS = "com.mysql.jdbc.Driver";

    /**
     * Read Environment variables
     */
    public static void getEnvVar() {
        try {
            String tDB_URL = System.getenv("DB_URL");
            String tUSER_NAME = System.getenv("USER_NAME");
            String tPASSWORD = System.getenv("PASSWORD");
            String tDRIVER_CLASS = System.getenv("DRIVER_CLASS");

            if (tDB_URL != null && tUSER_NAME != null && tPASSWORD != null && tDRIVER_CLASS != null) {
                DB_URL = tDB_URL;
                USER_NAME = tUSER_NAME;
                PASSWORD = tPASSWORD;
                DRIVER_CLASS = tDRIVER_CLASS;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     *
     * @return
     */
    private static Connection getConnection() {
        getEnvVar();
        String meomeo = "";
        Connection conn = null;
        try {
            Class.forName(DRIVER_CLASS);
            conn = DriverManager.getConnection(DB_URL, USER_NAME, PASSWORD);
            if (conn != null) {
                meomeo = "connection OK";
            }
            else {
                meomeo = "connection FAIL";
            }
            System.out.print(meomeo);
        }
        catch (Exception ex) {
            ex.printStackTrace();
        }
        return conn;
    }

    /**
     *
     * @param query
     * @return
     */
    public ResultSet dbExecuteQuery(String query) {
        ResultSet rSet = null;
        Connection conn = getConnection();
        try {
            Statement stmt = conn.createStatement();
            rSet = stmt.executeQuery(query);
            //conn.close();
        }
        catch (Exception ex) {
            ex.printStackTrace();
        }
        return rSet;
    }

    /**
     *
     * @param query
     */
    public void dbExecuteUpdate(String query) {
        Connection conn = getConnection();
        try {
            Statement stmt = conn.createStatement();
            stmt.executeUpdate(query);
            //conn.close();
        }
        catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    /**
     *
     * @param query
     * @return
     */
    public Statement dbExecuteScalar(String query) {
        Statement stmt = null;
        Connection conn = getConnection();
        try {
            stmt = conn.createStatement();
            stmt.execute(query);
            //conn.close();
        }
        catch (Exception ex) {
            ex.printStackTrace();
        }
        return stmt;
    }
}
