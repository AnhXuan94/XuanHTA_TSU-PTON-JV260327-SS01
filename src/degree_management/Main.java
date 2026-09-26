package degree_management;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Scanner;

public class Main {
    private static final DegreeDAO dao = new DegreeDAO();
    private static final SimpleDateFormat DF = new SimpleDateFormat("dd/MM/yyyy HH:mm");

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        boolean running = true;

        while (running) {
            printMenu();
            String choice = sc.nextLine().trim();
            try {
                switch (choice) {
                    case "1": listAll(); break;
                    case "2": addNew(sc); break;
                    case "3": updateDegree(sc); break;
                    case "4": deleteDegree(sc); break;
                    case "5": searchByName(sc); break;
                    case "6":
                        running = false;
                        System.out.println("Da thoat chuong trinh. Tam biet!");
                        break;
                    default: System.out.println("Lua chon khong hop le (1-6).");
                }
            } catch (SQLException e) {
                System.out.println("Loi CSDL: " + e.getMessage());
            }
        }
        sc.close();
    }

    private static void printMenu() {
        System.out.println("\n********** DEGREES MANAGEMENT **********");
        System.out.println("1. Danh sach cac bang cap");
        System.out.println("2. Them moi mot bang cap");
        System.out.println("3. Cap nhat bang cap");
        System.out.println("4. Xoa bang cap");
        System.out.println("5. Tim kiem bang cap theo ten");
        System.out.println("6. Thoat");
        System.out.print("Chon chuc nang: ");
    }
// 1. Hien thi danh sach cac bang cap
    private static void listAll() throws SQLException {
        List<Degree> list = dao.getAll();
        printTable(list);
    }
// 2. them moi bang cap
    private static void addNew(Scanner sc) throws SQLException {
        System.out.println("--- Them moi bang cap ---");
        String name = InputUtil.readNonEmptyString(sc, "Ten bang cap: ", 150);
        String empId = InputUtil.readEmpId(sc);
        Timestamp date = InputUtil.readDateTime(sc, "Ngay cap bang");
        String school = InputUtil.readNonEmptyString(sc, "Ten truong: ", 100);
        int year = InputUtil.readDegreeYear(sc);
        String classif = InputUtil.readNonEmptyString(sc, "Xep loai (Gioi/Kha/TB...): ", 20);

        dao.add(new Degree(name, empId, date, school, year, classif));
        System.out.println("-> Da them bang cap thanh cong!");
    }
// 3. cap nhat bang cap
    private static void updateDegree(Scanner sc) throws SQLException {
        System.out.println("--- Cap nhat bang cap ---");
        // De bai yeu cau "sua dung thong tin dua vao degree_id"
        // Nhung de tien dung, ta co the hoi ID hoac EmpID. O day lam theo ID cho chac.
        System.out.print("Nhap degree_id can sua: ");
        int id = Integer.parseInt(sc.nextLine().trim());

        Degree old = dao.findById(id);
        if (old == null) {
            System.out.println("-> Khong tim thay bang cap voi ID = " + id);
            return;
        }

        System.out.println("Thong tin cu: " + old.getDegreeName() + " - " + old.getEmpId());
        System.out.println("Nhap thong tin moi:");

        String name = InputUtil.readNonEmptyString(sc, "Ten bang cap moi: ", 150);
        String empId = InputUtil.readEmpId(sc);
        Timestamp date = InputUtil.readDateTime(sc, "Ngay cap bang moi");
        String school = InputUtil.readNonEmptyString(sc, "Ten truong moi: ", 100);
        int year = InputUtil.readDegreeYear(sc);
        String classif = InputUtil.readNonEmptyString(sc, "Xep loai moi: ", 20);

        dao.update(new Degree(id, name, empId, date, school, year, classif));
        System.out.println("-> Cap nhat thanh cong!");
    }
// 4. xoa bang cap
    private static void deleteDegree(Scanner sc) throws SQLException {
        System.out.println("--- Xoa bang cap ---");
        System.out.print("Nhap degree_id can xoa: ");
        int id = Integer.parseInt(sc.nextLine().trim());

        Degree old = dao.findById(id);
        if (old == null) {
            System.out.println("-> Khong tim thay de xoa.");
            return;
        }
        System.out.println("Ban dang xoa: " + old.getDegreeName());

        if (InputUtil.confirm(sc, "Ban co chac chan muon xoa?")) {
            boolean ok = dao.delete(id);
            System.out.println(ok ? "-> Da xoa." : "-> Xoa that bai.");
        } else {
            System.out.println("-> Da huy xoa.");
        }
    }
// 5. tim kiem bang cap theo ten
    private static void searchByName(Scanner sc) throws SQLException {
        System.out.print("Nhap ten bang cap can tim: ");
        String keyword = sc.nextLine().trim();
        List<Degree> list = dao.searchByName(keyword);
        printTable(list);
    }

    private static void printTable(List<Degree> list) {
        if (list.isEmpty()) {
            System.out.println("Khong co du lieu.");
            return;
        }
        // Format bang cho dep
        System.out.printf("%-5s %-20s %-10s %-18s %-20s %-6s %-10s%n",
                "ID", "Ten Bang", "Ma NV", "Ngay Cap", "Truong", "Nam", "Xep Loai");
        System.out.println("-".repeat(100));
        for (Degree d : list) {
            System.out.printf("%-5d %-20s %-10s %-18s %-20s %-6d %-10s%n",
                    d.getDegreeId(),
                    truncate(d.getDegreeName(), 20),
                    d.getEmpId(),
                    DF.format(d.getDegreeDate()),
                    truncate(d.getSchoolName(), 20),
                    d.getDegreeYear(),
                    d.getDegreeClassification());
        }
    }

    private static String truncate(String s, int max) {
        return (s != null && s.length() > max) ? s.substring(0, max - 3) + "..." : s;
    }
}