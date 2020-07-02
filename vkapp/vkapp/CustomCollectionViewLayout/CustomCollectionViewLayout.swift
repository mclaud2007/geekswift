//
//  CustomCollectionViewLayoutAbstract.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 05.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

class CustomCollectionViewLayout: UICollectionViewLayout {
    private var layoutCache = [IndexPath: UICollectionViewLayoutAttributes]()
    private var columnsYOffset: [CGFloat]!
    private var columnsXOffset: [CGFloat]!
    
    private var contentSize: CGSize!
    
    private var totalColumns = 2
    private var totalItemsInRow = 3
    private var interItemsSpacing: CGFloat = 5
    private var totalItemsInOddRowCount: Int = 0
    
    private var itemWidthRatio: CGFloat = 0.3
    private var itemHeightRatio: CGFloat = 1
    
    private var bigElementSize: CGSize!
    private var smallElementSize: CGSize!
    
    var contentInsets: UIEdgeInsets {
        return collectionView!.contentInset
    }
    
    override var collectionViewContentSize: CGSize {
        return self.contentSize
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        
        // Очищаем кэш размеров ячеек
        layoutCache.removeAll()
        
        // Создаем массив равный числу колонок содержащий 0
        columnsYOffset = Array(repeating: 0, count: totalColumns)
        
        var contentSizeHeight:CGFloat = 0
        
        // Посчитаем размеры элементов коллекции
        calculateItemsSize()
        
        for section in 0..<collectionView.numberOfSections {
            // Число элементов в секции
            let numberOfItem = collectionView.numberOfItems(inSection: section)
            
            for item in 0..<numberOfItem {
                let indexPath = IndexPath(row: item, section: section)
                let columnIndex = columnIndexForItemAt(indexPath: indexPath)
                
                // Создаем квадрат для элемента
                let attributeRect = calculateItemFrame(indexPath: indexPath, columnIndex: columnIndex, columnYoffset: columnsYOffset[columnIndex])
                let targetLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                targetLayoutAttributes.frame = attributeRect
                
                // Считаем высоту элемента
                contentSizeHeight = max(attributeRect.maxY, contentSizeHeight)
                columnsYOffset[columnIndex] = attributeRect.maxY + interItemsSpacing
                layoutCache[indexPath] = targetLayoutAttributes
            }
        }
        
        contentSize = CGSize(width: collectionView.bounds.width - contentInsets.left - contentInsets.right,
                             height: contentSizeHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributesArray = [UICollectionViewLayoutAttributes]()
        
        for layoutAttributes in layoutCache {
            if rect.intersects(layoutAttributes.value.frame) {
                layoutAttributesArray.append(layoutAttributes.value)
            }
        }
        
        return layoutAttributesArray
    }
    
    private func calculateItemsSize() {
        guard let collectionView = collectionView else { return }
        
        // Ширина collectionView без отстуопв слева и справа
        let contentWithoutIndents = collectionView.bounds.width - contentInsets.left - contentInsets.right
        let resolvedContentWidth = contentWithoutIndents - interItemsSpacing
        let floatItemsInRow = CGFloat(totalItemsInRow)
        
        // Ширина и высота стандартного элемента
        let smallItemWidth = resolvedContentWidth * itemWidthRatio
        let smallItemHeight = smallItemWidth * itemHeightRatio
        
        smallElementSize = CGSize(width: smallItemWidth, height: smallItemHeight)

        // Большой элемент у нас один - его ширина это ширина всей коллекции - минус ширина маленького
        let bigItemWidth = resolvedContentWidth - smallItemWidth
        let bigItemHeight = smallItemHeight * floatItemsInRow + ((floatItemsInRow - 1) * interItemsSpacing)
        
        bigElementSize = CGSize(width: bigItemWidth, height: bigItemHeight)
    }
    
    private func columnIndexForItemAt(indexPath: IndexPath) -> Int {
        let totalItemsInRowPlus = totalItemsInRow + 1
        let columnIndex = indexPath.item % totalItemsInRowPlus
        let rowIndex = indexPath.item / totalItemsInRowPlus
        let columnIndexLimit = totalColumns - 1

        if (rowIndex % 2 == 0) {
            return columnIndex > columnIndexLimit  ? columnIndexLimit : columnIndex
        } else {
            // Не достигли ли предел размещения в первой колонке четной строки
            let isFirstCollOfOddRowReady = (totalItemsInOddRowCount < totalItemsInRow)
            
            // Если вывели меньше чем число разрешенных элементов в строке, то увеличим счетчик в противном случае обнулим
            totalItemsInOddRowCount = isFirstCollOfOddRowReady ? (totalItemsInOddRowCount + 1) : 0
            
            return isFirstCollOfOddRowReady ? 0 : columnIndexLimit
        }
    }
    
    private func calculateItemFrame(indexPath: IndexPath, columnIndex: Int, columnYoffset: CGFloat) -> CGRect {
        let rowIndex = indexPath.item / (totalItemsInRow + 1)
        
        if (rowIndex % 2 == 0 && columnIndex == 0) {
            return CGRect(origin: CGPoint(x: 0.0, y: columnYoffset), size: bigElementSize)
        } else if (rowIndex % 2 == 0 && columnIndex == 1) {
            return CGRect(origin: CGPoint(x: bigElementSize.width + interItemsSpacing, y: columnYoffset), size: smallElementSize)
        } else if (rowIndex % 2 > 0 && columnIndex == 0) {
            return CGRect(origin: CGPoint(x: 0.0, y: columnYoffset), size: smallElementSize)
        } else {
            return CGRect(origin: CGPoint(x: smallElementSize.width + interItemsSpacing, y: columnYoffset), size: bigElementSize)
        }
    }
}
