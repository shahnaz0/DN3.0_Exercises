--Tablestructure
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
  VALUES (1, 'Alice Johnson', 'Manager', 70000, 'HR', TO_DATE('1900-07-20', 'YYYY-MM-DD'));

  INSERT INTO Employees (EmployeeID, Name, Position, Salary, Department, HireDate)
  VALUES (2, 'Bob Brown', 'Developer', 60000, 'IT', TO_DATE('2017-03-20', 'YYYY-MM-DD'));
END;
/

 --Ex4 Scenario 1: Calculate Age
 
CREATE OR REPLACE FUNCTION CalculateAge(
  p_DOB IN DATE
) RETURN NUMBER IS
  v_Age NUMBER;
BEGIN
  v_Age := TRUNC(MONTHS_BETWEEN(SYSDATE, p_DOB) / 12);
  RETURN v_Age;
END;
/

DECLARE
  v_Age NUMBER;
BEGIN
  -- Call the CalculateAge function with a sample date of birth
  v_Age := CalculateAge(TO_DATE('1950-05-15', 'YYYY-MM-DD'));
  DBMS_OUTPUT.PUT_LINE('Age: ' || v_Age);
END;
/
--Ex4 Scenario 2: Calculate Monthly Installment

CREATE OR REPLACE FUNCTION CalculateMonthlyInstallment(
  p_LoanAmount IN NUMBER,
  p_InterestRate IN NUMBER,
  p_LoanDuration IN NUMBER
) RETURN NUMBER IS
  v_MonthlyInstallment NUMBER;
  v_RatePerMonth NUMBER;
  v_NumPayments NUMBER;
BEGIN
  v_RatePerMonth := p_InterestRate / 100 / 12;  -- Convert annual interest rate to monthly
  v_NumPayments := p_LoanDuration * 12;          -- Total number of monthly payments

  IF p_InterestRate = 0 THEN
    v_MonthlyInstallment := p_LoanAmount / v_NumPayments;  -- Simple division if interest rate is 0
  ELSE
    v_MonthlyInstallment := (p_LoanAmount * v_RatePerMonth) / (1 - POWER(1 + v_RatePerMonth, -v_NumPayments));
  END IF;

  -- Round the monthly installment to two decimal places
  RETURN ROUND(v_MonthlyInstallment, 2);
END;
/

DECLARE
  v_Installment NUMBER;
BEGIN
  v_Installment := CalculateMonthlyInstallment(5000, 5, 5);
  DBMS_OUTPUT.PUT_LINE('Monthly Installment: ' || v_Installment);
END;
/
--Ex3 Scenario3: Check Sufficient Balance

CREATE OR REPLACE FUNCTION HasSufficientBalance(
  p_AccountID IN Accounts.AccountID%TYPE,
  p_Amount IN NUMBER
) RETURN BOOLEAN IS
  v_Balance Accounts.Balance%TYPE;
BEGIN
  SELECT Balance INTO v_Balance
  FROM Accounts
  WHERE AccountID = p_AccountID;

  RETURN v_Balance >= p_Amount;  -- Return TRUE if balance is sufficient, otherwise FALSE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;  -- If the account does not exist, return FALSE
END;
/
DECLARE
  v_HasSufficient BOOLEAN;
BEGIN
  -- Call the HasSufficientBalance function with a sample account ID and amount
  v_HasSufficient := HasSufficientBalance(1, 500);  -- Check if Account ID 1 has at least 500

  -- Output the result as 'TRUE' or 'FALSE'
  DBMS_OUTPUT.PUT_LINE('Has Sufficient Balance: ' || CASE WHEN v_HasSufficient THEN 'TRUE' ELSE 'FALSE' END);
END;
/