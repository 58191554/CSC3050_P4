def check(file_number = 1):
    f1 = open("RAM.txt","r")
    ls1 = f1.readlines()
    name = "cpu_test\DATA_RAM"+str(file_number)+".txt"
    f2 = open(name, "r")
    ls2 = f2.readlines()
    if len(ls1) != len(ls2):
        print("内存数量不同")
        return
    for i in range(len(ls1)):
        if ls1[i] != ls2[i]:
            print("第", i+1, "行不同")
            return
    print("file "+str(file_number)+" 完全相同！")

check(int(input()))