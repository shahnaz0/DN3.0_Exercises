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

 --Ex6 Scenario 1:  Generate Monthly Statements for All Customers
 
DECLARE
  CURSOR transaction_cursor IS
    SELECT c.CustomerID, c.Name, t.TransactionID, t.TransactionDate, t.Amount, t.TransactionType
    FROM Customers c
    JOIN Accounts a ON c.CustomerID = a.CustomerID
    JOIN Transactions t ON a.AccountID = t.AccountID
    WHERE EXTRACT(MONTH FROM t.TransactionDate) = EXTRACT(MONTH FROM SYSDATE)
      AND EXTRACT(YEAR FROM t.TransactionDate) = EXTRACT(YEAR FROM SYSDATE);

  v_CustomerID Customers.CustomerID%TYPE;
  v_CustomerName Customers.Name%TYPE;
  v_TransactionID Transactions.TransactionID%TYPE;
  v_TransactionDate Transactions.TransactionDate%TYPE;
  v_Amount Transactions.Amount%TYPE;
  v_TransactionType Transactions.TransactionType%TYPE;

BEGIN
  OPEN transaction_cursor;

  LOOP
    FETCH transaction_cursor INTO v_CustomerID, v_CustomerName, v_TransactionID, v_TransactionDate, v_Amount, v_TransactionType;
    EXIT WHEN transaction_cursor%NOTFOUND;

    DBMS_OUTPUT.PUT_LINE('Customer ID: ' || v_CustomerID || 
                         ', Name: ' || v_CustomerName || 
                         ', Transaction ID: ' || v_TransactionID || 
                         ', Date: ' || TO_CHAR(v_TransactionDate, 'YYYY-MM-DD') || 
                         ', Amount: ' || v_Amount || 
                         ', Type: ' || v_TransactionType);
  END LOOP;

  CLOSE transaction_cursor;
END;
/

--Ex5 Scenario 2: Apply Annual Fee to All Accounts

DECLARE
  CURSOR account_cursor IS
    SELECT AccountID, Balance
    FROM Accounts;

  v_AccountID Accounts.AccountID%TYPE;
  v_Balance Accounts.Balance%TYPE;
  v_AnnualFee NUMBER := 50;  -- Define the annual maintenance fee

BEGIN
  OPEN account_cursor;

  LOOP
    FETCH account_cursor INTO v_AccountID, v_Balance;
    EXIT WHEN account_cursor%NOTFOUND;

    -- Deduct the annual fee from the account balance
    UPDATE Accounts
    SET Balance = v_Balance - v_AnnualFee
    WHERE AccountID = v_AccountID;
    
    DBMS_OUTPUT.PUT_LINE('Applied annual fee to Account ID: ' || v_AccountID || 
                         ', New Balance: ' || (v_Balance - v_AnnualFee));
  END LOOP;

  CLOSE account_cursor;

  COMMIT;  -- Commit the changes
END;
/
--Ex6 Scenario3: Update Interest Rates for All Loans

DECLARE
  CURSOR loan_cursor IS
    SELECT LoanID, InterestRate
    FROM Loans;

  v_LoanID Loans.LoanID%TYPE;
  v_CurrentRate Loans.InterestRate%TYPE;
  v_NewRate Loans.InterestRate%TYPE;

BEGIN
  OPEN loan_cursor;

  LOOP
    FETCH loan_cursor INTO v_LoanID, v_CurrentRate;
    EXIT WHEN loan_cursor%NOTFOUND;

    -- Update the interest rate based on a new policy (e.g., increase by 1%)
    v_NewRate := v_CurrentRate + 1;  -- Example policy: increase by 1%

    UPDATE Loans
    SET InterestRate = v_NewRate
    WHERE LoanID = v_LoanID;

    DBMS_OUTPUT.PUT_LINE('Updated Loan ID: ' || v_LoanID || 
                         ', Old Rate: ' || v_CurrentRate || 
                         ', New Rate: ' || v_NewRate);
  END LOOP;

  CLOSE loan_cursor;

  COMMIT;  -- Commit the changes
END;
/