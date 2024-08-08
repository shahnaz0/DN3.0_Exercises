--Table structure

BEGIN
  -- Create Customers Table
  EXECUTE IMMEDIATE 'CREATE TABLE Customers (
    CustomerID NUMBER PRIMARY KEY,
    Name VARCHAR2(100),
    DOB DATE,
    Balance NUMBER,
    LastModified DATE
  )';

  -- Create Accounts Table
  EXECUTE IMMEDIATE 'CREATE TABLE Accounts (
    AccountID NUMBER PRIMARY KEY,
    CustomerID NUMBER,
    AccountType VARCHAR2(20),
    Balance NUMBER,
    LastModified DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
  )';

  -- Create Transactions Table
  EXECUTE IMMEDIATE 'CREATE TABLE Transactions (
    TransactionID NUMBER PRIMARY KEY,
    AccountID NUMBER,
    TransactionDate DATE,
    Amount NUMBER,
    TransactionType VARCHAR2(10),
    FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
  )';

  -- Create Loans Table
  EXECUTE IMMEDIATE 'CREATE TABLE Loans (
    LoanID NUMBER PRIMARY KEY,
    CustomerID NUMBER,
    LoanAmount NUMBER,
    InterestRate NUMBER,
    StartDate DATE,
    EndDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
  )';

  -- Create Employees Table
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
  -- Insert into Customers
  INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified)
  VALUES (1, 'John Doe', TO_DATE('1950-05-15', 'YYYY-MM-DD'), 1000, SYSDATE);

  INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified)
  VALUES (2, 'Jane Smith', TO_DATE('1947-07-20', 'YYYY-MM-DD'), 1500, SYSDATE);

  -- Insert into Accounts
  INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, LastModified)
  VALUES (1, 1, 'Savings', 1000, SYSDATE);

  INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, LastModified)
  VALUES (2, 2, 'Checking', 1500, SYSDATE);

  -- Insert into Transactions
  INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
  VALUES (1, 1, SYSDATE, 200, 'Deposit');

  INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
  VALUES (2, 2, SYSDATE, 300, 'Withdrawal');

  -- Insert into Loans
  INSERT INTO Loans (LoanID, CustomerID, LoanAmount, InterestRate, StartDate, EndDate)
  VALUES (1, 1, 5000, 5, SYSDATE, ADD_MONTHS(SYSDATE, 60));
  INSERT INTO Loans (LoanID, CustomerID, LoanAmount, InterestRate, StartDate, EndDate)
  VALUES (2, 2, 5000, 10, SYSDATE, ADD_MONTHS(SYSDATE, 60));

  -- Insert into Employees
  INSERT INTO Employees (EmployeeID, Name, Position, Salary, Department, HireDate)
  VALUES (1, 'Alice Johnson', 'Manager', 70000, 'HR', TO_DATE('2015-06-15', 'YYYY-MM-DD'));

  INSERT INTO Employees (EmployeeID, Name, Position, Salary, Department, HireDate)
  VALUES (2, 'Bob Brown', 'Developer', 60000, 'IT', TO_DATE('2017-03-20', 'YYYY-MM-DD'));
END;
/

--EX2 Scenario 1: Handle Exceptions During Fund Transfers Between Accounts

CREATE OR REPLACE PROCEDURE SafeTransferFunds(
  acc1 IN Accounts.AccountID%TYPE,
  acc2 IN Accounts.AccountID%TYPE,
  amount IN Accounts.Balance%TYPE
)
IS
  Funds_Insufficient EXCEPTION;
  From_Acc_Balance Accounts.Balance%TYPE;
BEGIN
  -- Retrieve balance from the source account
  SELECT Balance INTO From_Acc_Balance FROM Accounts WHERE AccountID = acc1;
  IF From_Acc_Balance < amount THEN
    RAISE Funds_Insufficient;
  END IF;

  DBMS_OUTPUT.PUT_LINE('*** TRANSFER DONE SUCCESSFULLY ***');
  
EXCEPTION
  WHEN Funds_Insufficient THEN 
    DBMS_OUTPUT.PUT_LINE('*** INSUFFICIENT AMOUNT ***');
END;
/
BEGIN
  SafeTransferFunds(acc1 => 1, acc2 => 2, amount => 500);
END;
/

--EX2 Scenario 2: Manage Errors When Updating Employee Salaries
CREATE OR REPLACE PROCEDURE ModifyEmployeeSalary(
  p_EmployeeID IN Employees.EmployeeID%TYPE,
  p_SalaryIncrease IN NUMBER
)
IS
  empNotFound EXCEPTION;
  empCount NUMBER;
BEGIN
  -- Check if the employee exists in the database
  SELECT COUNT(*) INTO empCount FROM Employees WHERE EmployeeID = p_EmployeeID;
  
  IF empCount < 1 THEN
    RAISE empNotFound;
  END IF;
  
  -- Update the employee's salary based on the provided increase percentage
  UPDATE Employees
  SET Salary = Salary + (Salary * p_SalaryIncrease / 100)
  WHERE EmployeeID = p_EmployeeID;
  
  -- Output success message
  DBMS_OUTPUT.PUT_LINE('Salary updated successfully for Employee ID: ' || p_EmployeeID);
  
EXCEPTION
  WHEN empNotFound THEN
    DBMS_OUTPUT.PUT_LINE('Error: Employee ID ' || p_EmployeeID || ' does not exist.');
END;
/

-- Example call to the procedure
BEGIN
  ModifyEmployeeSalary(p_EmployeeID => 4, p_SalaryIncrease => 5);
END;
/
--EX2   Scenario 3: Ensure Data Integrity When Adding a New Customer

CREATE OR REPLACE PROCEDURE AddNewCustomer(
    customerID IN NUMBER,
    customerName IN VARCHAR2,
    customerDOB IN DATE,
    customerBalance IN NUMBER,
    customerLastModified IN DATE
)
IS
  CustomerExists EXCEPTION;
  customerCount NUMBER;
BEGIN
  -- Check if a customer with the given ID already exists
  SELECT count(*) INTO customerCount FROM Customers WHERE CustomerID = customerID;
  
  IF customerCount > 0 THEN
    RAISE CustomerExists;
  END IF;
  
  -- Insert the new customer record
  INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified)
  VALUES (customerID, customerName, customerDOB, customerBalance, customerLastModified);
  
  DBMS_OUTPUT.PUT_LINE('Customer registered successfully');
  
EXCEPTION
  WHEN CustomerExists THEN
    DBMS_OUTPUT.PUT_LINE('Error: Customer ID already exists');
END;
/
BEGIN
  AddNewCustomer(
    customerID => 1,
    customerName => 'sravya',
    customerDOB => SYSDATE,
    customerBalance => 10000,
    customerLastModified => SYSDATE
  );
END;
/
