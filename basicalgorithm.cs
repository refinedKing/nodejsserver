public static void Main (string[] args)
{
	List<int> list = GetList ();

	Stopwatch sw = new Stopwatch ();
	sw.Start ();
	QSort (list,0,list.Count-1);
	Console.Write( Binary_Search (list,list.Count-1, 28));
	sw.Stop ();
	Console.WriteLine ("耗时毫秒" + sw.ElapsedMilliseconds);
}

public static List<int> GetList()
{
	List<int> list = new List<int> ();
	Random random = new Random ();
	for (int i = 0; i < 3 * 50 * 1024; i++) {
		if (i < (50 * 1024)) 
		{
			list.Add (random.Next (10000, 500000) % 34);
		}
		else if (i < (2 * 50 * 1024)) 
		{
			list.Add ((random.Next (1,2) * 100000) / ((i % 3) == 0 ? 1 : i % 3));
		} else {
			list.Add (i / 3);
		}
	}

	return list;
}

public static List<int> swap(List<int> list, int i,int j)
{
	int temp = list[i];
	list[i] = list[j];
	list[j] = temp;
	return list;
}

// 冒泡
public static List<int> BubbleSort(List<int> list)
{
	// 3104
	for (int i = 0; i < list.Count; i++) {
		for (int j = i + 1; j < list.Count; j++) {
			if (list[i] > list[j]) {
				swap (list, i, j);
			}
		}
	}
	return list;
}

public static List<int> BubbleSort1(List<int> list)
{
	// 5619
	for (int i = 1; i < list.Count; i++) {
		for (int j = list.Count -2; j >= i; j--) {
			if (list[j] > list[j + 1]) {
				swap (list, j, j + 1);
			}
		}
	}
	return list;
}

// 快速
public static List<int> QSort(List<int> list,int low,int high)
{
	int pivot;
	if (low < high) {
		pivot = Partion (list, low, high);

		QSort (list, low, pivot - 1);
		QSort (list, pivot + 1, high);
	}
	return list;
}

static int Partion(List<int> list,int low,int high)
{
	int pivotkey = list[low];
	while (low < high) {
		while (low < high && list[high] >= pivotkey) {
			high--;
		}
		swap (list, low, high);
		while (low < high && list[low] <= pivotkey) {
			low++;
		}
		swap (list, low, high);
	}
	return low;
}

// 查询
// 普通
static int Search(List<int> list,int key)
{
	// 9654
	for (int i = 0; i < list.Count; i++) {
		if (list[i] == key) {
			return list [i];
		}
	}
	return 0;
}

// 二分
static int Binary_Search(List<int> list,int n,int key)
{
	int low, high, mid;
	low = 1;
	high = n;
	while (low < high) {
		//mid = (low + high) / 2;
		mid = low + (high - low) * (key - list [low]) / (list [high] - list [low]);

		if (key < list [mid]) {
			high = mid - 1;
		} else if (key > list [mid]) {
			low = mid + 1;
		} else {
			return list[mid];
		}
	}
	return 0;
}
