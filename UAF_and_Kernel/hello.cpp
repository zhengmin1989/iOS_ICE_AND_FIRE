//#import "talker.h"
//#import "worker.h"
//#import "human.h"
#include <iostream>

using namespace std;

class Human
{
public:
    virtual void setValue(int value)=0;
    virtual int getValue()=0;
    
protected:
    int mValue;
};

class Talker : public Human
{
public:
    void setValue(int value){
        mValue = value;
    }
    int getValue(){
        mValue += 1;
        cout<<"This is Talker's getValue"<<endl;
        return mValue;
    }
};


class Worker : public Human
{
public:
    void setValue(int value){
        mValue = value;
    }
    int getValue(){
        cout<<"This is Worker's getValue"<<endl;
        mValue += 100;
        return mValue;
    }
};

void handleObject(Human* human)
{
    human->setValue(0);
    cout<<human->getValue()<<endl;
}


int main(void) {

        Talker *myTalker = new Talker();
        printf("myTalker=%p\n",myTalker);

        handleObject(myTalker);
 
        free(myTalker);
/*
        Worker *myWorker = new Worker();
        printf("myWorker=%p\n",myWorker);

        handleObject(myTalker);
*/
///*        
        int size=16;
        void *uafTalker = (void*) malloc(size);
        memset(uafTalker, 0x41,size);
        printf("uafTalker=%p\n",uafTalker);

        handleObject(myTalker);
//*/
        return 0;
    
}

