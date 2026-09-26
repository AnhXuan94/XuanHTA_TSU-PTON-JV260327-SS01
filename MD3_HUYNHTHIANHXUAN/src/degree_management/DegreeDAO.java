package degree_management;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DegreeDAO {

    private Degree mapRow(ResultSet rs) throws SQLException {
        return new Degree(
                rs.getInt("degree_id"),
                rs.getString("degree_name"),
                rs.getString("emp_id"),
                rs.getTimestamp("degree_date"),
                rs.getString("school_name"),
                rs.getInt("degree_year"),
                rs.getString("degree_classification")
        );
    }

    // 1. Danh sach tat ca
    public List<Degree> getAll() throws SQLException {
        List<Degree> list = new ArrayList<>();
        String sql = "{CALL sp_get_all_degrees()}";
        try (Connection conn = DBConnection.getConnection();
             CallableStatement stmt = conn.prepareCall(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    // 2. Them moi
    public void add(Degree d) throws SQLException {
        String sql = "{CALL sp_add_degree(?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnection.getConnection();
             CallableStatement stmt = conn.prepareCall(sql)) {
            stmt.setString(1, d.getDegreeName());
            stmt.setString(2, d.getEmpId());
            stmt.setTimestamp(3, d.getDegreeDate());
            stmt.setString(4, d.getSchoolName());
            stmt.setInt(5, d.getDegreeYear());
            stmt.setString(6, d.getDegreeClassification());
            stmt.execute();
        }
    }

    // 3. Tim theo emp_id (Dung de check ton tai truoc khi update/delete)
    public List<Degree> getByEmpId(String empId) throws SQLException {
        List<Degree> list = new ArrayList<>();
        String sql = "{CALL sp_get_degrees_by_emp_id(?)}";
        try (Connection conn = DBConnection.getConnection();
             CallableStatement stmt = conn.prepareCall(sql)) {
            stmt.setString(1, empId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    // 4. Cap nhat
    public void update(Degree d) throws SQLException {
        String sql = "{CALL sp_update_degree(?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnection.getConnection();
             CallableStatement stmt = conn.prepareCall(sql)) {
            stmt.setInt(1, d.getDegreeId());
            stmt.setString(2, d.getDegreeName());
            stmt.setString(3, d.getEmpId());
            stmt.setTimestamp(4, d.getDegreeDate());
            stmt.setString(5, d.getSchoolName());
            stmt.setInt(6, d.getDegreeYear());
            stmt.setString(7, d.getDegreeClassification());
            stmt.execute();
        }
    }

    // 5. Xoa
    public boolean delete(int id) throws SQLException {
        String sql = "{CALL sp_delete_degree(?)}";
        try (Connection conn = DBConnection.getConnection();
             CallableStatement stmt = conn.prepareCall(sql)) {
            stmt.setInt(1, id);
            stmt.execute();
            return stmt.getUpdateCount() > 0;
        }
    }

    // 6. Tim kiem theo ten
    public List<Degree> searchByName(String keyword) throws SQLException {
        List<Degree> list = new ArrayList<>();
        String sql = "{CALL sp_search_degrees_by_name(?)}";
        try (Connection conn = DBConnection.getConnection();
             CallableStatement stmt = conn.prepareCall(sql)) {
            stmt.setString(1, keyword);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    // Helper: Tim 1 bang cap theo ID de hien thi truoc khi sua/xoa
    public Degree findById(int id) throws SQLException {
        // Vi de bai chi yeu cau SP tim theo emp_id, nen ta viet query truc tiep cho ID
        // Hoac ban co them SP sp_get_degree_by_id neu muan chuan 100% SP
        String sql = "SELECT * FROM degrees WHERE degree_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }
}