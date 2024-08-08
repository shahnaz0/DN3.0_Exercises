BEGIN
  -- Create a Customers Table
  EXECUTE IMMEDIATE 'CREATE TABLE Customers (
    CustomerID NUMBER PRIMARY KEY,
    Name VARCHAR2(100),
    DOB DATE,
    Balance NUMBER,
    LastModified DATE
  )';

  -- Create a Accounts Table
  EXECUTE IMMEDIATE 'CREATE TABLE Accounts (
    AccountID NUMBER PRIMARY KEY,
    CustomerID NUMBER,
    AccountType VARCHAR2(20),
    Balance NUMBER,
    LastModified DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
  )';

  -- Create a Transactions Table
  EXECUTE IMMEDIATE 'CREATE TABLE Transactions (
    TransactionID NUMBER PRIMARY KEY,
    AccountID NUMBER,
    TransactionDate DATE,
    Amount NUMBER,
    TransactionType VARCHAR2(10),
    FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
  )';

  -- Create a Loans Table
  EXECUTE IMMEDIATE 'CREATE TABLE Loans (
    LoanID NUMBER PRIMARY KEY,
    CustomerID NUMBER,
    LoanAmount NUMBER,
    InterestRate NUMBER,
    StartDate DATE,
    EndDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
  )';

  -- Create a Employees Table
  EXECUTE IMMEDIATE 'CREATE TABLE Employees (
    EmployeeID NUMBER PRIMARY KEY,
    Name VARCHAR2(100),
    Position VARCHAR2(50),
    Salary NUMBER,
    Department VARCHAR2(50),
    HireDate DATE
  )';
END;
/
BEGIN
  -- Insert into Customers table
  INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified)
  VALUES (1, 'John Doe', TO_DATE('1985-05-15', 'YYYY-MM-DD'), 1000, SYSDATE);

  INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified)
  VALUES (2, 'Jane Smith', TO_DATE('1990-07-20', 'YYYY-MM-DD'), 1500, SYSDATE);

  -- Insert into Accounts table
  INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, LastModified)
  VALUES (1, 1, 'Savings', 1000, SYSDATE);

  INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, LastModified)
  VALUES (2, 2, 'Checking', 1500, SYSDATE);

  -- Insert into Transactions table
  INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
  VALUES (1, 1, SYSDATE, 200, 'Deposit');

  INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
  VALUES (2, 2, SYSDATE, 300, 'Withdrawal');

  -- Insert into Loans table
  INSERT INTO Loans (LoanID, CustomerID, LoanAmount, InterestRate, StartDate, EndDate)
  VALUES (1, 1, 5000, 5, SYSDATE, ADD_MONTHS(SYSDATE, 60));
  INSERT INTO Loans (LoanID, CustomerID, LoanAmount, InterestRate, StartDate, EndDate)
  VALUES (2, 2, 5000, 10, SYSDATE, ADD_MONTHS(SYSDATE, 60));

  -- Insert into Employees table
  INSERT INTO Employees (EmployeeID, Name, Position, Salary, Department, HireDate)
  VALUES (1, 'Alice Johnson', 'Manager', 70000, 'HR', TO_DATE('2015-06-15', 'YYYY-MM-DD'));

  INSERT INTO Employees (EmployeeID, Name, Position, Salary, Department, HireDate)
  VALUES (2, 'Bob Brown', 'Developer', 60000, 'IT', TO_DATE('2017-03-20', 'YYYY-MM-DD'));
END;
/
--------------------------------------------------------------------

----Scenario-1
CREATE OR REPLACE PACKAGE pkg_CustomerManagement AS
  PROCEDURE proc_AddCustomer(
    p_CustomerID IN NUMBER,
    p_Name IN VARCHAR2,
    p_DOB IN DATE,
    p_Balance IN NUMBER
  );

  PROCEDURE proc_UpdateCustomerDetails(
    p_CustomerID IN NUMBER,
    p_Name IN VARCHAR2,
    p_DOB IN DATE
  );

  FUNCTION func_GetCustomerBalance(
    p_CustomerID IN NUMBER
  ) RETURN NUMBER;
END pkg_CustomerManagement;
/

CREATE OR REPLACE PACKAGE BODY pkg_CustomerManagement AS

  PROCEDURE proc_AddCustomer(
    p_CustomerID IN NUMBER,
    p_Name IN VARCHAR2,
    p_DOB IN DATE,
    p_Balance IN NUMBER
  ) IS
  BEGIN
    INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified)
    VALUES (p_CustomerID, p_Name, p_DOB, p_Balance, SYSDATE);

    DBMS_OUTPUT.PUT_LINE('Customer added successfully: ' || p_CustomerID);
  END proc_AddCustomer;

  PROCEDURE proc_UpdateCustomerDetails(
    p_CustomerID IN NUMBER,
    p_Name IN VARCHAR2,
    p_DOB IN DATE
  ) IS
  BEGIN
    UPDATE Customers
    SET Name = p_Name,
        DOB = p_DOB,
        LastModified = SYSDATE
    WHERE CustomerID = p_CustomerID;

    DBMS_OUTPUT.PUT_LINE('Customer details updated successfully: ' || p_CustomerID);
  END proc_UpdateCustomerDetails;

  FUNCTION func_GetCustomerBalance(
    p_CustomerID IN NUMBER
  ) RETURN NUMBER IS
    v_Balance NUMBER;
  BEGIN
    SELECT Balance
    INTO v_Balance
    FROM Customers
    WHERE CustomerID = p_CustomerID;

    RETURN v_Balance;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001, 'Error retrieving customer balance.');
  END func_GetCustomerBalance;

END pkg_CustomerManagement;
/

BEGIN
  pkg_CustomerManagement.proc_AddCustomer(3, 'Michael Johnson', TO_DATE('1978-11-25', 'YYYY-MM-DD'), 2000);
  pkg_CustomerManagement.proc_UpdateCustomerDetails(1, 'John Doe Jr.', TO_DATE('1985-05-15', 'YYYY-MM-DD'));
  
  DECLARE
    v_CustomerBalance NUMBER;
  BEGIN
    v_CustomerBalance := pkg_CustomerManagement.func_GetCustomerBalance(1);
    DBMS_OUTPUT.PUT_LINE('Customer balance: ' || v_CustomerBalance);
  END;
END;
/




--Scenario:2
CREATE OR REPLACE PACKAGE EmployeeManagement AS
  PROCEDURE HireEmployee(
    employee_id IN NUMBER,
    name IN VARCHAR2,
    position IN VARCHAR2,
    salary IN NUMBER,
    department IN VARCHAR2,
    hire_date IN DATE
  );

  PROCEDURE UpdateEmployeeDetails(
    employee_id IN NUMBER,
    name IN VARCHAR2,
    position IN VARCHAR2,
    salary IN NUMBER,
    department IN VARCHAR2
  );

  FUNCTION CalculateAnnualSalary(
    employee_id IN NUMBER
  ) RETURN NUMBER;
END EmployeeManagement;
/
CREATE OR REPLACE PACKAGE BODY EmployeeManagement AS

  PROCEDURE HireEmployee(
    employee_id IN NUMBER,
    name IN VARCHAR2,
    position IN VARCHAR2,
    salary IN NUMBER,
    department IN VARCHAR2,
    hire_date IN DATE
  ) IS
  BEGIN
    INSERT INTO Employees (EmployeeID, Name, Position, Salary, Department, HireDate)
    VALUES (employee_id, name, position, salary, department, hire_date);

    DBMS_OUTPUT.PUT_LINE('Employee hired successfully: ' || employee_id);
  END HireEmployee;

  PROCEDURE UpdateEmployeeDetails(
    employee_id IN NUMBER,
    name IN VARCHAR2,
    position IN VARCHAR2,
    salary IN NUMBER,
    department IN VARCHAR2
  ) IS
  BEGIN
    UPDATE Employees
    SET Name = name,
        Position = position,
        Salary = salary,
        Department = department
    WHERE EmployeeID = employee_id;

    DBMS_OUTPUT.PUT_LINE('Employee details updated successfully: ' || employee_id);
  END UpdateEmployeeDetails;

  FUNCTION CalculateAnnualSalary(
    employee_id IN NUMBER
  ) RETURN NUMBER IS
    emp_salary NUMBER;
  BEGIN
    SELECT Salary
    INTO emp_salary
    FROM Employees
    WHERE EmployeeID = employee_id;

    RETURN emp_salary * 12;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001, 'Error calculating annual salary.');
  END CalculateAnnualSalary;

END EmployeeManagement;
/
BEGIN
  -- Test HireEmployee
  EmployeeManagement.HireEmployee(
    employee_id => 3, 
    name => 'Sarah Connor', 
    position => 'Analyst', 
    salary => 5000, 
    department => 'Finance', 
    hire_date => TO_DATE('2023-01-15', 'YYYY-MM-DD')
  );

  -- Test UpdateEmployeeDetails
  EmployeeManagement.UpdateEmployeeDetails(
    employee_id => 1, 
    name => 'Alice Johnson', 
    position => 'Senior Manager', 
    salary => 80000, 
    department => 'HR'
  );

  -- Test CalculateAnnualSalary
  DECLARE
    annual_salary NUMBER;
  BEGIN
    annual_salary := EmployeeManagement.CalculateAnnualSalary(1);
    DBMS_OUTPUT.PUT_LINE('Annual salary: ' || annual_salary);
  END;
END;
/



--Scenario:3
CREATE OR REPLACE PACKAGE AccountOperations AS
  PROCEDURE OpenAccount(
    account_id IN NUMBER,
    customer_id IN NUMBER,
    account_type IN VARCHAR2,
    initial_balance IN NUMBER
  );

  PROCEDURE CloseAccount(
    account_id IN NUMBER
  );

  FUNCTION GetTotalBalance(
    customer_id IN NUMBER
  ) RETURN NUMBER;
END AccountOperations;
/
CREATE OR REPLACE PACKAGE BODY AccountOperations AS

  PROCEDURE OpenAccount(
    account_id IN NUMBER,
    customer_id IN NUMBER,
    account_type IN VARCHAR2,
    initial_balance IN NUMBER
  ) IS
  BEGIN
    INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, LastModified)
    VALUES (account_id, customer_id, account_type, initial_balance, SYSDATE);

    DBMS_OUTPUT.PUT_LINE('Account opened successfully: ' || account_id);
  END OpenAccount;

  PROCEDURE CloseAccount(
    account_id IN NUMBER
  ) IS
  BEGIN
    DELETE FROM Transactions
    WHERE AccountID = account_id;

    DELETE FROM Accounts
    WHERE AccountID = account_id;

    DBMS_OUTPUT.PUT_LINE('Account closed successfully: ' || account_id);
  END CloseAccount;

  FUNCTION GetTotalBalance(
    customer_id IN NUMBER
  ) RETURN NUMBER IS
    total_balance NUMBER;
  BEGIN
    SELECT SUM(Balance)
    INTO total_balance
    FROM Accounts
    WHERE CustomerID = customer_id;

    RETURN total_balance;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001, 'Error calculating total balance.');
  END GetTotalBalance;

END AccountOperations;
/
BEGIN
  -- Test OpenAccount
  AccountOperations.OpenAccount(
    account_id => 3, 
    customer_id => 1, 
    account_type => 'Checking', 
    initial_balance => 2000
  );

  -- Test CloseAccount
  AccountOperations.CloseAccount(account_id => 2);

  -- Test GetTotalBalance
  DECLARE
    total_balance NUMBER;
  BEGIN
    total_balance := AccountOperations.GetTotalBalance(1);
    DBMS_OUTPUT.PUT_LINE('Total balance for customer 1: ' || total_balance);
  END;
END;
/




























