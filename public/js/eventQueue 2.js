// Event Queue is simply a priority Queue, basic implementation O(n^2)

class EventQueue {
  constructor(size) {
    this.size=size;
	this.queue=new Array(size);
	this.frontIndex=0;
	this.time=0;
  }

  add(obj,delay){

	  if(obj.queueProperties.inQueue){
		  obj.queueProperties.time=this.time+(delay||obj.propagationDelay);
		  let i=obj.queueProperties.index;
		  while(i>0 && obj.queueProperties.time>this.queue[i-1].queueProperties.time){
			  this.swap(i,i-1)
			  i--;
		  }
		  i=obj.queueProperties.index;
		  while(i<this.frontIndex-1 && obj.queueProperties.time<this.queue[i+1].queueProperties.time){
			  this.swap(i,i+1);
			  i++;
		  }
		  return;
	  }

	  if(this.frontIndex==this.size) throw "EventQueue size exceeded";
	  this.queue[this.frontIndex]=obj;
	  // console.log(this.time)
	  // obj.queueProperties.time=obj.propagationDelay;
	  obj.queueProperties.time=this.time+(delay||obj.propagationDelay);
	  obj.queueProperties.index=this.frontIndex;
	  this.frontIndex++;
	  obj.queueProperties.inQueue=true;
	  let i=obj.queueProperties.index;
	  while(i>0 && obj.queueProperties.time>this.queue[i-1].queueProperties.time){
		  this.swap(i,i-1)
		  i--;
	  }

  }
  addImmediate(obj){
	  this.queue[this.frontIndex]=obj;
	  obj.queueProperties.time=this.time;
	  obj.queueProperties.index=this.frontIndex;
	  obj.queueProperties.inQueue=true;
	  this.frontIndex++;
  }

  swap(v1,v2){
	  let obj1= this.queue[v1];
	  obj1.queueProperties.index=v2;

	  let obj2= this.queue[v2];
	  obj2.queueProperties.index=v1;

	  this.queue[v1]=obj2;
	  this.queue[v2]=obj1;
  }

  pop(){
	 if(this.isEmpty())throw "Queue Empty"

	 this.frontIndex--;
	 let obj=this.queue[this.frontIndex]
	 this.time=obj.queueProperties.time;
	 obj.queueProperties.inQueue=false;
	 return obj;
  }

  reset(){
	  for(let i=0;i<this.frontIndex;i++)
	  	this.queue[i].queueProperties.inQueue=false
	  this.time=0
	  this.frontIndex=0;
  }

  isEmpty(){
	  return this.frontIndex==0;
  }

}
