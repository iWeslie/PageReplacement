# Page Replacement Simulation

> 操作系统页面置换算法模拟实现 Swift 版本，这里是 [参考链接](http://c.biancheng.net/cpp/html/2614.html)

已实现算法如下：

### 最佳置换算法(OPT)

- 最优 (Optimal) 页面置换算法：由Belady于1966年提出的一种理论上的算法。其所选择的被淘汰页面，将是以后永不使用的或许是在最长的未来时间内不再被访问的页面。采用最佳置换算法，通常可保证获得最低的缺页率。但由于操作系统其实无法预知一个应用程序在执行过程中访问到的若干页中，哪一个页是未来最长时间内不再被访问的，因而该算法是无法实际实现，但可以此算法作为上限来评价其它的页面置换算法。
- 先进先出(First In First Out, FIFO)页面置换算法：该算法总是淘汰最先进入内存的页，即选择在内存中驻留时间最久的页予以淘汰。只需把一个应用程序在执行过程中已调入内存的页按先后次序链接成一个队列，队列头指向内存中驻留时间最久的页，队列尾指向最近被调入内存的页。这样需要淘汰页时，从队列头很容易查找到需要淘汰的页。FIFO算法只是在应用程序按线性顺序访问地址空间时效果才好，否则效率不高。因为那些常被访问的页，往往在内存中也停留得最久，结果它们因变“老”而不得不被置换出去。FIFO算法的另一个缺点是，它有一种异常现象（Belady现象），即在增加放置页的页帧的情况下，反而使缺页异常次数增多。
- LRU(Least Recently Used，LRU)页面置换算法： FIFO置换算法性能之所以较差，是因为它所依据的条件是各个页调入内存的时间，而页调入的先后顺序并不能反映页是否“常用”的使用情况。最近最久未使用（LRU）置换算法，是根据页调入内存后的使用情况进行决策页是否“常用”。由于无法预测各页面将来的使用情况，只能利用“最近的过去”作为“最近的将来”的近似，因此，LRU置换算法是选择最近最久未使用的页予以淘汰。该算法赋予每个页一个访问字段，用来记录一个页面自上次被访问以来所经历的时间t,，当须淘汰一个页面时，选择现有页面中其t值最大的，即最近最久未使用的页面予以淘汰。

## OPT

| 访问页面 | 7    | 0    | 1    | 2    | 0    | 3    | 0    | 4    | 2    | 3    | 0    | 3    | 2    | 1    | 2    | 0    | 1    | 7    | 0    | 1    |
| -------- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| 物理块1  | 7    | 7    | 7    | 2    |      | 2    |      | 2    |      |      | 2    |      |      | 2    |      |      |      | 7    |      |      |
| 物理块2  |      | 0    | 0    | 0    |      | 0    |      | 4    |      |      | 0    |      |      | 0    |      |      |      | 0    |      |      |
| 物理块3  |      |      | 1    | 1    |      | 3    |      | 3    |      |      | 3    |      |      | 1    |      |      |      | 1    |      |      |
| 缺页否   | √    |      | √    | √    |      | √    |      | √    |      |      | √    |      |      | √    |      |      |      | √    |      |      |

![opt](http://iweslie.com/github/opt.png)

## FIFO

| 访问页面 | 7    | 0    | 1    | 2    | 0    | 3    | 0    | 4    | 2    | 3    | 0    | 3    | 2    | 1    | 2    | 0    | 1    | 7    | 0    | 1    |
| -------- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| 物理块1  | 7    | 7    | 7    | 2    |      | 2    | 2    | 4    | 4    | 4    | 0    |      |      | 0    | 0    |      |      | 7    | 7    | 7    |
| 物理块2  |      | 0    | 0    | 0    |      | 3    | 3    | 3    | 2    | 2    | 2    |      |      | 1    | 1    |      |      | 1    | 0    | 0    |
| 物理块3  |      |      | 1    | 1    |      | 1    | 0    | 0    | 0    | 3    | 3    |      |      | 3    | 2    |      |      | 2    | 2    | 1    |
| 缺页否   | √    | √    | √    | √    |      | √    | √    | √    | √    | √    | √    |      |      | √    | √    |      |      | √    | √    | √    |

![fifo](http://iweslie.com/github/fifo.png)

## LRU

![lru](http://iweslie.com/github/lru.png)



未实现：

- 二次机会（Second Chance）页面置换算法：为了克服FIFO算法的缺点，人们对它进行了改进。此算法在页表项（PTE）中设置了一位访问位来表示此页表项对应的页当前是否被访问过。当该页被访问时，CPU中的MMU硬件将把访问位置“1”。当需要找到一个页淘汰时，对于最“老”的那个页面，操作系统去检查它的访问位。如果访问位是0，说明这个页面老且无用，应该立刻淘汰出局；如果访问位是1，这说明该页面曾经被访问过，因此就再给它一次机会。具体来说，先把访问位位清零，然后把这个页面放到队列的尾端，并修改它的装入时间，就好像它刚刚进入系统一样，然后继续往下搜索。二次机会算法的实质就是寻找一个比较古老的、而且从上一次缺页异常以来尚未被访问的页面。如果所有的页面都被访问过了，它就退化为纯粹的FIFO算法。
- 时钟（Clock）页面置换算法：也称最近未使用 (Not Used Recently, NUR) 页面置换算法。虽然二次机会算法是一个较合理的算法，但它经常需要在链表中移动页面，这样做既降低了效率，又是不必要的。一个更好的办法是把各个页面组织成环形链表的形式，类似于一个钟的表面。然后把一个指针指向最古老的那个页面，或者说，最先进来的那个页面。时钟算法和第二次机会算法的功能是完全一样的，只是在具体实现上有所不同。时钟算法需要在页表项（PTE）中设置了一位访问位来表示此页表项对应的页当前是否被访问过。当该页被访问时，CPU中的MMU硬件将把访问位置“1”。然后将内存中所有的页都通过指针链接起来并形成一个循环队列。初始时，设置一个当前指针指向某页（比如最古老的那个页面）。操作系统需要淘汰页时，对当前指针指向的页所对应的页表项进行查询，如果访问位为“0”，则淘汰该页，把它换出到硬盘上；如果访问位为“1”，这将该页表项的此位置“0”，继续访问下一个页。该算法近似地体现了LRU的思想，且易于实现，开销少。但该算法需要硬件支持来设置访问位，且该算法在本质上与FIFO算法是类似的，惟一不同的是在clock算法中跳过了访问位为1的页。
- 改进的时钟（Enhanced Clock）页面置换算法：在时钟置换算法中，淘汰一个页面时只考虑了页面是否被访问过，但在实际情况中，还应考虑被淘汰的页面是否被修改过。因为淘汰修改过的页面还需要写回硬盘，使得其置换代价大于未修改过的页面。改进的时钟置换算法除了考虑页面的访问情况，还需考虑页面的修改情况。即该算法不但希望淘汰的页面是最近未使用的页，而且还希望被淘汰的页是在主存驻留期间其页面内容未被修改过的。这需要为每一页的对应页表项内容中增加一位引用位和一位修改位。当该页被访问时，CPU中的MMU硬件将把访问位置“1”。当该页被“写”时，CPU中的MMU硬件将把修改位置“1”。这样这两位就存在四种可能的组合情况：（0，0）表示最近未被引用也未被修改，首先选择此页淘汰；（0，1）最近未被使用，但被修改，其次选择；（1，0）最近使用而未修改，再次选择；（1，1）最近使用且修改，最后选择。该算法与时钟算法相比，可进一步减少磁盘的I/O操作次数，但为了查找到一个尽可能适合淘汰的页面，可能需要经过多次扫描，增加了算法本身的执行开销。