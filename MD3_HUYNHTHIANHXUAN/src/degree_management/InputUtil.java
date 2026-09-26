package degree_management;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Scanner;

public class InputUtil {
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    public static String readNonEmptyString(Scanner sc, String prompt, int maxLength) {
        while (true) {
            System.out.print(prompt);
            String input = sc.nextLine().trim();
            if (input.isEmpty()) {
                System.out.println(" -> Khong duoc de trong!");
                continue;
            }
            if (maxLength > 0 && input.length() > maxLength) {
                System.out.println(" -> Toi da " + maxLength + " ky tu!");
                continue;
            }
            return input;
        }
    }

    // emp_id
    public static String readEmpId(Scanner sc) {
        while (true) {
            System.out.print("Ma nhan vien (max 15 ky tu): ");
            String input = sc.nextLine().trim();
            if (input.isEmpty()) {
                System.out.println(" -> Khong duoc de trong!");
            } else if (input.length() > 15) {
                System.out.println(" -> Ma nhan vien toi da 15 ky tu!");
            } else {
                return input;
            }
        }
    }

    // nam cap bang
    public static int readDegreeYear(Scanner sc) {
        while (true) {
            System.out.print("Nam cap bang (VD: 2023): ");
            String input = sc.nextLine().trim();
            try {
                int year = Integer.parseInt(input);
                if (year < 1900 || year > 2100) {
                    System.out.println(" -> Nam khong hop le!");
                    continue;
                }
                return year;
            } catch (NumberFormatException e) {
                System.out.println(" -> phai la so nguyen!");
            }
        }
    }

    public static Timestamp readDateTime(Scanner sc, String label) {
        while (true) {
            System.out.print(label + " (dd/MM/yyyy HH:mm): ");
            String input = sc.nextLine().trim();
            try {
                LocalDateTime dt = LocalDateTime.parse(input, DATE_FORMAT);
                return Timestamp.valueOf(dt);
            } catch (DateTimeParseException e) {
                System.out.println(" -> Sai dinh dang! VD: 20/09/2026 14:30");
            }
        }
    }

    public static boolean confirm(Scanner sc, String prompt) {
        while (true) {
            System.out.print(prompt + " (Y/N): ");
            String input = sc.nextLine().trim().toUpperCase();
            if (input.equals("Y")) return true;
            if (input.equals("N")) return false;
            System.out.println(" -> Chi nhap Y hoac N.");
        }
    }
}