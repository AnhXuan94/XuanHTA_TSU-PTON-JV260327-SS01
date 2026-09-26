package degree_management;

import java.sql.Timestamp;

public class Degree {
    private int degreeId;
    private String degreeName;
    private String empId;
    private Timestamp degreeDate;
    private String schoolName;
    private int degreeYear;
    private String degreeClassification;

    public Degree(int degreeId, String degreeName, String empId, Timestamp degreeDate,
                  String schoolName, int degreeYear, String degreeClassification) {
        this.degreeId = degreeId;
        this.degreeName = degreeName;
        this.empId = empId;
        this.degreeDate = degreeDate;
        this.schoolName = schoolName;
        this.degreeYear = degreeYear;
        this.degreeClassification = degreeClassification;
    }

    public Degree(String degreeName, String empId, Timestamp degreeDate,
                  String schoolName, int degreeYear, String degreeClassification) {
        this(0, degreeName, empId, degreeDate, schoolName, degreeYear, degreeClassification);
    }

    public int getDegreeId() { return degreeId; }
    public String getDegreeName() { return degreeName; }
    public String getEmpId() { return empId; }
    public Timestamp getDegreeDate() { return degreeDate; }
    public String getSchoolName() { return schoolName; }
    public int getDegreeYear() { return degreeYear; }
    public String getDegreeClassification() { return degreeClassification; }
}