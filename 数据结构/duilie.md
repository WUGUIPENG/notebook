# 队列
### 队列的基本概念： 尾进头出
>1 队列是一种特殊的线性表：插入限定在表的某一段进行，删除限定在表的一段进行

>2 队尾：允许插入的一端

>3 对头：允许删除的一端

>4 空队列：不含任何数据元素的队列

队列的特点：先进先出/后进后出
预定：队尾指针指示尾元素当前的位置，对头指针指示对头元素的前一个元素

假溢出：队列实际上没有满， 但是不能插入元素称为假溢出
### 循环队列：首位相连

顺序队列的四要素sq：
>1 队列空条件：sq.front == sq.rear

>2 队列满条件：(sq.rear+1)%maxsize == sq.front

>3 元素入队列：

>4 队列元素出队列

注意：显然这种条件下的队满条件下， 队满条件成立是队列中还有一个空闲单元也就是说这样的队列中最多只能进Maxsize-1个元素

### 连式队列
队列的连式存储结构称为链队，它实际上是一个同时带有对头指针front和队尾指针rear的单列表，对头指针指向对头节点， 队尾指针指向队尾节点即单列表的最后一个节点，并将对头和队尾结合起来构成链队节点

连式队列的四要素：
>1 对空条件： front==rear

>2 队满条件满，不考虑(因为每个节点是动态分布的)

>3 元素x入队：创建节点p，将其插入到队尾， 并由rear指向它， P.data  = x

>4 出对操作：删除对头节点:

出对操作需要进行一下判断

>1 判断列是否为空， 队列为空无法出队

>2 队列里有一个数据


```python
if self.front.next.next == None:
				self.front.next = None
				self.rear = self.front

```
>3 队列里有两个或两个以上的元素
```
tNode = self.front.next #记住出对的元素
self.front == tNode.next #对头指针指向出对元素的下一个
return tNode.data #返回出对元素
```


